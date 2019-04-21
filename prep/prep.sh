#!/bin/bash

# Load Variables
. ./load-variables.sh

# Deploy prep-template to create R53, S3, output Name Servers.
sam deploy --stack-name docaas-devlab --template-file prep/prep-template.yaml --capabilities CAPABILITY_NAMED_IAM --region $REGION


