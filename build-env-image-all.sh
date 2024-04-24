#!/bin/bash
docker build -t dataquadrant/sagemaker-notebook-base-2024:latest base
docker push dataquadrant/sagemaker-notebook-base-2024:latest

docker build -t dataquadrant/sagemaker-notebook-2024:python3 -f envs/docker/Dockerfile.python3 envs
docker push dataquadrant/sagemaker-notebook-2024:python3

docker build -t dataquadrant/sagemaker-notebook-2024:all_python3 -f envs/docker/Dockerfile.all_python3 envs
docker push dataquadrant/sagemaker-notebook-2024:all_python3

docker build -t dataquadrant/sagemaker-notebook-2024:python2 -f envs/docker/Dockerfile.python2 envs
docker push dataquadrant/sagemaker-notebook-2024:python2

docker build -t dataquadrant/sagemaker-notebook-2024:all_python2 -f envs/docker/Dockerfile.all_python2 envs
docker push dataquadrant/sagemaker-notebook-2024:all_python2

docker build -t dataquadrant/sagemaker-notebook-2024:all -f envs/docker/Dockerfile.all envs
docker push dataquadrant/sagemaker-notebook-2024:all





