# Pulumi deployments custom image

# https://github.com/pulumi/pulumi-docker-containers/blob/main/docker/python/Dockerfile

ARG PYTHON_VERSION="3.11"

FROM python:${PYTHON_VERSION}-slim AS builder

RUN apt-get update -y && \
    apt-get upgrade -y && \
    apt-get install -y \
    curl \
    build-essential \
    git \
    unzip
    

# Install Poetry
ENV POETRY_HOME="/opt/poetry"
RUN curl -sSL https://install.python-poetry.org/ | python

# Install Pulumi
RUN curl -fsSL https://get.pulumi.com | sh

# Install AWS CLI
ARG TARGETARCH
RUN if [ "${TARGETARCH}" = "arm64" ]; then ARCH="aarch64"; else ARCH="x86_64"; fi && \
    curl "https://awscli.amazonaws.com/awscli-exe-linux-${ARCH}.zip" -o "awscliv2.zip" && \
    unzip awscliv2.zip
RUN ./aws/install --install-dir /opt/aws-cli --bin-dir /usr/local/bin


FROM python:${PYTHON_VERSION}-slim AS run

# Install needed tools, like git
RUN apt-get update -y && \
    apt-get install -y \
    curl \
    git \
    ca-certificates \
    && apt-get clean

WORKDIR /pulumi/projects

# Copy Poetry from builder stage
COPY --from=builder /opt/poetry /opt/poetry
ENV PATH="/opt/poetry/bin:${PATH}"

# Copy Pulumi from builder stage
COPY --from=builder /root/.pulumi/bin/pulumi /pulumi/bin/pulumi
COPY --from=builder /root/.pulumi/bin/*-python* /pulumi/bin/
ENV PATH "/pulumi/bin:${PATH}"

# Copy AWS CLI from builder stage
COPY --from=builder /opt/aws-cli /opt/aws-cli
COPY --from=builder /usr/local/bin /usr/local/bin

CMD ["pulumi"]