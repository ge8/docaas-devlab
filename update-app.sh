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
# Sign users out bronze1, silver1, gold1
aws cognito-idp admin-user-global-sign-out --user-pool-id $USERPOOLID --username bronze1
aws cognito-idp admin-user-global-sign-out --user-pool-id $USERPOOLID --username silver1
aws cognito-idp admin-user-global-sign-out --user-pool-id $USERPOOLID --username gold1
