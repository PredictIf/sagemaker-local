#!/bin/bash


######################################################################################
# https://github.com/PredictIf/sagemaker-local
git init
git add .
git commit -m "first commit"
git branch -M main
git remote add origin https://github.com/PredictIf/sagemaker-local.git
git push -u origin main

######################################################################################

./run-python3-container.sh

chmod -R 700 base
chmod -R 755 base

# ##############################################################################
# https://github.com/aws/deep-learning-containers/blob/master/available_images.md
aws ecr get-login-password --region us-east-2 | docker login --username AWS --password-stdin 763104351884.dkr.ecr.us-east-2.amazonaws.com
docker build -t my-sagemaker-notebook .
docker run -e AWS_ACCESS_KEY_ID=your_access_key -e AWS_SECRET_ACCESS_KEY=your_secret_key -p 8888:8888 my-sagemaker-notebook
docker run -v ~/.aws:/root/.aws -p 8888:8888 my-sagemaker-notebook

# http://127.0.0.1:8888/tree?token=68804eb01f4610fe239cda03fa0cee1608955c857f9bbc89


./build-env-image-all.sh
