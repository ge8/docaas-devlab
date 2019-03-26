#!/bin/bash

. ./load-variables.sh

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
# Sign users out bronzeuser1, silveruser1, golduser1
aws cognito-idp admin-user-global-sign-out --user-pool-id $USERPOOLID --username bronzeuser1
aws cognito-idp admin-user-global-sign-out --user-pool-id $USERPOOLID --username silveruser1
aws cognito-idp admin-user-global-sign-out --user-pool-id $USERPOOLID --username golduser1
