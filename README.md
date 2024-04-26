# Amazon SageMaker Notebook Container

SageMaker Notebook Container is a sandboxed local environment that replicates the [Amazon Sagemaker Notebook Instance](https://docs.aws.amazon.com/sagemaker/latest/dg/nbi.html),
including installed software and libraries, file structure and permissions, environment variables, context objects and behaviors.

- [Amazon SageMaker Notebook Container](#amazon-sagemaker-notebook-container)
  - [Background](#background)
  - [Prerequisites](#prerequisites)
      - [Docker](#docker)
      - [AWS Credentials](#aws-credentials)
  - [Build The Image](#build-the-image)
  - [Run The Container](#run-the-container)
      - [Using `docker`](#using-docker)
      - [Using `docker-compose`](#using-docker-compose)
      - [Accessing Jupyter Notebook](#accessing-jupyter-notebook)
  - [Optional additions](#optional-additions)
      - [Docker CLI](#docker-cli)
      - [Git Integration](#git-integration)
      - [Shared `SageMaker` directory](#shared-sagemaker-directory)
  - [Sample scripts](#sample-scripts)


## Background
Amazon SageMaker provides us with an AWS-hosted Notebook instance, offering a convenient server environment for data scientists and developers like us to utilize its features.

However, this service incurs costs, requires us to upload data online, demands Internet access and AWS Console login, and poses challenges in customization.

To address these issues, we have developed a Docker container to provide a similar environment locally on our laptops or desktops.

This local setup replicates the functionalities of the AWS-hosted instance, including a complete Jupyter Notebook and Lab server, support for multiple kernels, integration with AWS & SageMaker SDKs, AWS and Docker CLIs, Git, Conda, and SageMaker Examples Tabs.

Both the AWS-hosted instance and our local Docker container complement each other, enhancing our overall data science experience.

<!-- #### Why a Docker image? -->
We choose a docker image instead of setting things locally because our primary goal is to create a repeatable setup that can be easily deployed on any laptop or server.

While most features can be directly installed on a laptop or desktop, this method often leads to maintenance challenges with each update of libraries and tools.

Moreover, when we work in teams, differences in machine setups can lead to compatibility issues, where applications functioning on one machine might fail on another.

By using a Docker image, we can ensure that all team members have the same environment, regardless of their operating system or machine specifications.

## Prerequisites

#### Docker

At the minimum, you'll need [Docker](https://docs.docker.com/install/#supported-platforms) engine installed and an account on [Docker Hub](https://hub.docker.com/). In these example scripts, we use `dataquadrant` as the Docker Hub account, you can replace it with your own account.

You should also have a basic understanding of Docker commands and Docker Compose.

#### AWS Credentials
For AWS SDK and CLI to work, you need to have AWS Credentials configured in the notebook.

It's recommended to have AWS Credentials configured on your local machine
so that you can use the same for the container (via volume mount)
and avoid the need to configure every time the container starts.

1. First install [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html) on your machine.
2. Then configure the [AWS Credentials](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html#cli-quick-configuration-multi-profiles) using your Access Key ID and Secret Access Key.
It's recommended to specify a profile name when configuring this, in case you have many accounts or many different user profiles in future:
```bash
aws configure --profile default-api
```
3. Note the profile name you have specified, it should be used as the value of the environment variable AWS_PROFILE for the container.

When running a container later on, you just need to add this volume mount `-v ~/.aws:/home/ec2-user/.aws:ro` (For Windows, replace `~` with `%USERPROFILE%`).

## Build The Image

1. Build the base image using one of command provided in `build-base-image.sh`
2. Build the final image using one of command provided in `build-env-image-all.sh`


## Run The Container

#### Using `docker`
The simplest way to start the `sagemaker-notebook-container` is to use `docker run` command:

**Unix:**
```bash
export CONTAINER_NAME=sagemaker-notebook-container
export IMAGE_NAME=<change it to your image name>
export WORKDDIR=/home/ec2-user
export AWS_PROFILE=default-api

docker run -t --name=${CONTAINER_NAME} \
           -p 8888:8888 \
           -e AWS_PROFILE=${AWS_PROFILE} \
           -v ~/.aws:${WORKDDIR}/.aws:ro \
           ${IMAGE_NAME}
```

#### Using `docker-compose`
If you have [Docker Compose](https://docs.docker.com/compose/install/) (already included in [Docker Desktop](https://docs.docker.com/install/#supported-platforms) for Windows and Mac),
you can use `docker-compose.yml` file so that you don't have to type the full docker run command.

```yaml
# docker-compose.yml
version: "3"
services:
  sagemaker-notebook-container:
    image: <change it to your image name>
    container_name: sagemaker-notebook-container
    ports:
      - 8888:8888
    environment:
      AWS_PROFILE: 'default-api'
    volumes:
      - ~/.aws:/home/ec2-user/.aws:ro                    # For AWS Credentials
```


*(Replace `default-api` with the appropriate profile name from your own `~/.aws/credentials`)*

With that, you can simply run this each time:
```bash
docker-compose up
```
or
```bash
docker-compose up sagemaker-notebook-container
```


#### Accessing Jupyter Notebook
You should see the following output, simply click on the `http://127.0.0.1:8888/...` link
(or copy paste to your browser) to access Jupyter:
```text
[I 03:10:12.757 NotebookApp] Writing notebook server cookie secret to /home/ec2-user/.local/share/jupyter/runtime/notebook_cookie_secret
[I 03:10:13.335 NotebookApp] JupyterLab extension loaded from /home/ec2-user/anaconda3/lib/python3.7/site-packages/jupyterlab
[I 03:10:13.335 NotebookApp] JupyterLab application directory is /home/ec2-user/anaconda3/share/jupyter/lab
[I 03:10:13.352 NotebookApp] [nb_conda] enabled
[I 03:10:13.373 NotebookApp] Serving notebooks from local directory: /home/ec2-user/SageMaker
[I 03:10:13.373 NotebookApp] The Jupyter Notebook is running at:
[I 03:10:13.373 NotebookApp] http://02b8db3c9e73:8888/?token=a22fc474c429a74650cb9ce74faf0ef2eedee182fc2eddec
[I 03:10:13.373 NotebookApp]  or http://127.0.0.1:8888/?token=a22fc474c429a74650cb9ce74faf0ef2eedee182fc2eddec
[I 03:10:13.373 NotebookApp] Use Control-C to stop this server and shut down all kernels (twice to skip confirmation).
```

## Optional additions

#### Docker CLI
Many SageMaker examples use docker to build custom images for training.

Instead of installing a full Docker on Docker, which is a complex operation, these images make use of the host's Docker Engine instead.

To achieve that, the Docker CLI is already installed on the base image and the Docker socket of the host machine is used to connect the host's Docker Engine.

This is achieved by including  when running the container.

```bash
-v /var/run/docker.sock:/var/run/docker.sock:ro
```

*(For Windows, update the mount to: `-v //var/run/docker.sock:/var/run/docker.sock:ro`)*

#### Git Integration
Git is installed on the base image to allow git access directly from the container.

Furthermore, the [jupyterlab-git](https://github.com/jupyterlab/jupyterlab-git) extension is installed on Jupyter Lab for quick GUI interaction with Git.

If you use connect to Git repository using SSH, then you need to mount the `.ssh` folder:
```bash
-v ~/.ssh:/home/ec2-user/.ssh:ro
```



#### Shared `SageMaker` directory
To save all work created in the container, mount a directory to act as the `SageMaker` directory under `/home/ec2-user`:
```bash
-v /Users/foobar/projects/SageMaker:/home/ec2-user/SageMaker
```
*(Replace `/Users/foobar/projects/SageMaker` with the appropriate folder from your own machine)*

## Sample scripts
Following sample scripts have been provided to show an example of running a container using `dataquadrant/sagemaker-notebook:python3` image:

```bash
docker run -t --name=sagemaker-notebook-container && \
           -p 8888:8888 && \
           -e AWS_PROFILE=default-api && \
           -v ~/.aws:/home/ec2-user/.aws:ro && \
           -v ~/.ssh:/home/ec2-user/.ssh:ro && \
           -v /Users/foobar/projects/SageMaker:/home/ec2-user/SageMaker && \
           dataquadrant/sagemaker-notebook:python3
```



`docker-compose.yml`:
```yaml
version: "3"
services:
  sagemaker-notebook-container:
    image: dataquadrant/sagemaker-notebook:python3
    container_name: sagemaker-notebook-container
    ports:
      - 8888:8888
    environment:
      AWS_PROFILE: "default-api"
    volumes:
      - ~/.aws:/home/ec2-user/.aws:ro                    # For AWS Credentials
      - ~/.ssh:/home/ec2-user/.ssh:ro                    # For Git Credentials
      - /var/run/docker.sock:/var/run/docker.sock:ro     # For Docker CLI
      - /Users/foobar/projects/SageMaker:/home/ec2-user/SageMaker    # For saving work in a host directory
```
*(Replace `/Users/foobar/projects/SageMaker` with the appropriate folder from your own machine)*
<!-- *(Replace `dataquadrant/sagemaker-notebook:python3` with the name of the container image built in the first step)* -->

The container can be started using:
```bash
docker-compose up sagemaker-notebook-container
```
