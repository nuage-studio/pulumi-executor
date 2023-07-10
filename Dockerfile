# Pulumi deployments custom image

# https://github.com/pulumi/pulumi-docker-containers/blob/main/docker/python/Dockerfile

ARG PYTHON_VERSION="3.11"

FROM python:${PYTHON_VERSION}-slim AS builder

RUN apt-get update -y && \
    apt-get upgrade -y && \
    apt-get install -y \
    curl \
    build-essential \
    git

# Install Poetry
ENV POETRY_HOME="/opt/poetry"
RUN curl -sSL https://install.python-poetry.org/ | python

# Install Pulumi
RUN curl -fsSL https://get.pulumi.com | sh


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

# Install AWS CLI
RUN pip install awscli

CMD ["pulumi"]