#!/bin/bash

# Deploy prep-template to create R53, S3, output Name Servers. us-east-1
sam deploy --stack-name docaas-devlab-prep2 --template-file prep/acm+c9-template.yaml --capabilities CAPABILITY_NAMED_IAM --region us-east-1

# Add records to R53 to validate ACM and wait



# Modify default DomainName in template.yaml 
ACCOUNT=$(aws sts get-caller-identity --output text --query 'Account')
TAIL="docaas-devlab"
export SAMBUCKET="$ACCOUNT-$TAIL"

# Modify default AcmCertificateArn in template.yaml from docaas-devlab-prep2 output


