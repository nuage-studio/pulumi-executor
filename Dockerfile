# Pulumi deployments custom image
ARG PYTHON_VERSION="3.11"
FROM python:${PYTHON_VERSION}


# Install needed tools, like git
RUN apt-get update -y && \
    apt-get install -y \
    curl \
    git \
    ca-certificates \
    && apt-get clean

# Install Poetry
ENV POETRY_HOME="/opt/poetry"
RUN curl -sSL https://install.python-poetry.org/ | python && rm -rf ~/.cache
ENV PATH="${POETRY_HOME}/bin:${PATH}"

# Install Pulumi
RUN curl -fsSL https://get.pulumi.com | sh
ENV PATH "/pulumi/bin:${PATH}"

WORKDIR /pulumi/projects

CMD ["pulumi"]