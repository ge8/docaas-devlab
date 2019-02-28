#!/bin/bash

export BUCKET=docaas-summit
# export DOMAIN=estaba.net
export REGION=ap-southeast-2
export STACK=cfn-docaas

# aws s3 cp cognito.yaml s3://docaas-summit
# aws cloudformation delete-stack --stack-name $STACK
# aws cloudformation wait stack-delete-complete --stack-name $STACK

sam package --template-file cf.yaml --s3-bucket $BUCKET --output-template-file packaged.yaml --region $REGION
sam deploy --template-file packaged.yaml --stack-name $STACK --capabilities CAPABILITY_NAMED_IAM --region $REGION

rm -f packaged.yaml
