#!/bin/bash

export SAMBUCKET=docaas-summit
export REGION=ap-southeast-2
export STACK=docaas-summit

# Grab DomainName from cloudformation output
DOMAINNAME=$(aws cloudformation describe-stacks --stack-name $STACK --query 'Stacks[0].Outputs[?OutputKey==`DomainName`].OutputValue' --output text)
# Configure DomainName in homepage (summit.docaas.net)
find frontend/package.json -type f -exec sed -i -e "s/summit.docaas.net/$DOMAINNAME/g" {} \;
rm -f frontend/package.json-e 

# Grab CloudfrontEndpoint from cloudformation output
CF=$(aws cloudformation describe-stacks --stack-name $STACK --query 'Stacks[0].Outputs[?OutputKey==`CloudfrontEndpoint`].OutputValue' --output text)
# Configure CF endpoint in MainBody
find ./frontend/src/components/MainBody -type f -exec sed -i -e "s/d276p75cmdbvss.cloudfront.net/$CF/g" {} \;
rm -f frontend/src/components/MainBody/MainBody.js-e frontend/src/components/MainBody/MainBody.css-e 

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

# Grab UserPoolID from cloudformation output
USERPOOLID=$(aws cloudformation describe-stacks --stack-name $STACK --query 'Stacks[0].Outputs[?OutputKey==`UserPoolId`].OutputValue' --output text)
# Create bronzeuser1, silveruser1, golduser1
aws cognito-idp admin-create-user --user-pool-id $USERPOOLID --username bronzeuser1 --user-attributes Name=email,Value=thisisnotgerardosemail+bronzeuser1@gmail.com Name=email_verified,Value=true Name=custom:plan,Value=bronze --temporary-password Temporary1!
aws cognito-idp admin-create-user --user-pool-id $USERPOOLID --username silveruser1 --user-attributes Name=email,Value=thisisnotgerardosemail+silveruser1@gmail.com Name=email_verified,Value=true Name=custom:plan,Value=silver --temporary-password Temporary1!
aws cognito-idp admin-create-user --user-pool-id $USERPOOLID --username golduser1 --user-attributes Name=email,Value=thisisnotgerardosemail+golduser1@gmail.com Name=email_verified,Value=true Name=custom:plan,Value=gold --temporary-password Temporary1!


