#!/bin/bash

export SAMBUCKET=docaas-summit
export REGION=ap-southeast-2
export STACK=docaas-summit


# Grab bucket name from cloudformation output
WEBBUCKET=$(aws cloudformation describe-stacks --stack-name $STACK --query 'Stacks[0].Outputs[?OutputKey==`TheBucket`].OutputValue' --output text)
echo $WEBBUCKET

# Build app
cd frontend
npm install
npm run-script build
cd ..


# Grab DomainName from cloudformation output
DOMAINNAME=$(aws cloudformation describe-stacks --stack-name $STACK --query 'Stacks[0].Outputs[?OutputKey==`DomainName`].OutputValue' --output text)
# Configure DomainName in homepage (summit.docaas.net)
find frontend/package.json -type f -exec sed -i -e "s/subdomain.domain.net/$DOMAINNAME/g" {} \;
rm -f frontend/package.json-e 

# Grab CloudfrontEndpoint from cloudformation output
CF=$(aws cloudformation describe-stacks --stack-name $STACK --query 'Stacks[0].Outputs[?OutputKey==`CloudfrontEndpoint`].OutputValue' --output text)
# Configure CF endpoint in MainBody





# Copy front-end public files to bucket
aws s3 sync frontend/build/ "s3://$WEBBUCKET" --delete


