#!/bin/bash

export SAMBUCKET=docaas-summit
export REGION=ap-southeast-2
export STACK=docaas-summit

# aws cloudformation delete-stack --stack-name $STACK
# aws cloudformation wait stack-delete-complete --stack-name $STACK

cd backend/src
npm install
cd ../..

sam package --template-file backend/template.yaml --s3-bucket $SAMBUCKET --output-template-file backend/packaged.yaml --region $REGION
sam deploy --template-file backend/packaged.yaml --stack-name $STACK --capabilities CAPABILITY_NAMED_IAM --region $REGION

rm -f backend/packaged.yaml
