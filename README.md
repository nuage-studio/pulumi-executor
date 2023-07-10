# Pulumi deployments executor

Custom executor to be used with Pulumi Deployments that contains Python (up to 3.11) and Poetry.

## Quickstart

To build the image locally:

```sh
docker build -t pulumi-executor .
```

To explore the image:

```sh
docker run -it pulumi-executor bash
```
