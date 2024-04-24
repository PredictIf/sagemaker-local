#!/bin/bash

# http://ec2-3-234-62-248.compute-1.amazonaws.com:9000/

cd base
docker build --platform linux/amd64 --no-cache -t dataquadrant/sagemaker-notebook-base:latest base
docker build --platform linux/amd64 --no-cache -t dataquadrant/sagemaker-notebook-base:latest .
docker build --no-cache -t dataquadrant/sagemaker-notebook-base:latest .
docker build -t dataquadrant/sagemaker-notebook-base-2024:latest .
docker build --platform linux/amd64 -t dataquadrant/sagemaker-notebook-base:latest .

docker push dataquadrant/sagemaker-notebook-base-2024:latest


# Alternatively:
# docker-compose build sagemaker-notebook-base
