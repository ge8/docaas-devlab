#!/bin/bash

# Deploy prep-template to create R53, S3, output Name Servers.
sam deploy --stack-name docaas-devlab-prep1 --template-file prep/prep-template.yaml --capabilities CAPABILITY_NAMED_IAM --region ap-southeast-2



