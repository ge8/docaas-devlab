#!/bin/bash

export SAMBUCKET=docaas-summit
export REGION=ap-southeast-2
export STACK=docaas-summit


# Build app
cd frontend
npm install
npm run-script build
cd ..

# Grab bucket name from cloudformation output
WEBBUCKET=$(aws cloudformation describe-stacks --stack-name $STACK --query 'Stacks[0].Outputs[?OutputKey==`TheBucket`].OutputValue' --output text)
echo $WEBBUCKET

# Copy front-end public files to bucket
aws s3 sync frontend/build/ "s3://$WEBBUCKET" --delete


