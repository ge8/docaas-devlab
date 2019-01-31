#!/bin/bash

export BUCKET=docaas-summit
export DOMAIN=estaba.net
export REGION=ap-southeast-2

aws s3 cp cognito.yaml docaas-summit

sam package --template-file master-template.yaml --s3-bucket $BUCKET --output-template-file packaged.yaml --region $REGION
sam deploy --template-file packaged.yaml --stack-name docaas-summit --capabilities CAPABILITY_NAMED_IAM --region $REGION

rm -f packaged.yaml
