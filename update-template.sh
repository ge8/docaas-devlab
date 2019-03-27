#!/bin/bash

# Load Variables
. ./load-variables.sh

# Package and Deploy SAM Template
sam package --template-file backend/template.yaml --s3-bucket $SAMBUCKET --output-template-file backend/packaged.yaml --region $REGION
sam deploy --template-file backend/packaged.yaml --stack-name $STACK --capabilities CAPABILITY_NAMED_IAM --region $REGION
rm -f backend/packaged.yaml

# API Gateway Deploy
RESTAPI=$(aws cloudformation describe-stacks --stack-name $STACK --query 'Stacks[0].Outputs[?OutputKey==`APIBaseURL`].OutputValue' --output text)
DEPID=$(aws apigateway create-deployment --rest-api-id $RESTAPI --stage-name Prod --query "id" --output text)
aws apigateway update-stage --rest-api-id $RESTAPI --stage-name Prod --patch-operations op='replace',path='/deploymentId',value=$DEPID
