#!/bin/bash

. ./load-variables.sh

# Grab DomainName from cloudformation output
DOMAINNAME=$(aws cloudformation describe-stacks --stack-name $STACK --query 'Stacks[0].Outputs[?OutputKey==`DomainName`].OutputValue' --output text)
# Configure DomainName in homepage (summit.docaas.net)
find frontend/package.json -type f -exec sed -i -e "s/summit.docaas.net/$DOMAINNAME/g" {} \;
rm -f frontend/package.json-e 


# Grab APIGW from cloudformation output
APIGW=$(aws cloudformation describe-stacks --stack-name $STACK --query 'Stacks[0].Outputs[?OutputKey==`APIBaseURL`].OutputValue' --output text)
# Configure APIGW endpoint in MainBody
find ./frontend/src/components/MainBody -type f -exec sed -i -e "s/dktoe4bhcl/$APIGW/g" {} \;
rm -f frontend/src/components/MainBody/MainBody.js-e frontend/src/components/MainBody/MainBody.css-e 
# Configure region in APIGW endpoint in MainBody
find ./frontend/src/components/MainBody -type f -exec sed -i -e "s/ap-southeast-2/$REGION/g" {} \;
rm -f frontend/src/components/MainBody/MainBody.js-e frontend/src/components/MainBody/MainBody.css-e 



# Grab UserPoolID, identitypoolid, webclientid from cloudformation output
USERPOOLID=$(aws cloudformation describe-stacks --stack-name $STACK --query 'Stacks[0].Outputs[?OutputKey==`UserPoolId`].OutputValue' --output text)
IDENTITYPOOLID=$(aws cloudformation describe-stacks --stack-name $STACK --query 'Stacks[0].Outputs[?OutputKey==`IdentityPoolId`].OutputValue' --output text)
WEBCLIENTID=$(aws cloudformation describe-stacks --stack-name $STACK --query 'Stacks[0].Outputs[?OutputKey==`UserPoolClientId`].OutputValue' --output text)
# Configure userpoolid in aws exports.
find ./frontend/src/aws-exports.js -type f -exec sed -i -e "s/ap-southeast-2_MxSPobwJs/$USERPOOLID/g" {} \;
# Configure identitypoolid in aws exports.
find ./frontend/src/aws-exports.js -type f -exec sed -i -e "s/ap-southeast-2:67e9f1c6-3e60-4cf5-895a-293073d57953/$IDENTITYPOOLID/g" {} \;
# Configure webclientid in aws exports.
find ./frontend/src/aws-exports.js -type f -exec sed -i -e "s/3pm8d10jnr7vk2ucdcuenp9nt9/$WEBCLIENTID/g" {} \;
# Configure region in aws exports.
find ./frontend/src/aws-exports.js -type f -exec sed -i -e "s/ap-southeast-2/$REGION/g" {} \;
rm -f frontend/src/aws-exports.js-e  




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

# Create bronze1, silver1, gold1
aws cognito-idp admin-create-user --user-pool-id $USERPOOLID --username bronze1 --user-attributes Name=email,Value=thisisnotgerardosemail+bronze1@gmail.com Name=email_verified,Value=true Name=custom:plan,Value=bronze --temporary-password Temporary1!
aws cognito-idp admin-create-user --user-pool-id $USERPOOLID --username silver1 --user-attributes Name=email,Value=thisisnotgerardosemail+silver1@gmail.com Name=email_verified,Value=true Name=custom:plan,Value=silver --temporary-password Temporary1!
aws cognito-idp admin-create-user --user-pool-id $USERPOOLID --username gold1 --user-attributes Name=email,Value=thisisnotgerardosemail+gold1@gmail.com Name=email_verified,Value=true Name=custom:plan,Value=gold --temporary-password Temporary1!

# Sign users out bronze1, silver1, gold1
aws cognito-idp admin-user-global-sign-out --user-pool-id $USERPOOLID --username bronze1
aws cognito-idp admin-user-global-sign-out --user-pool-id $USERPOOLID --username silver1
aws cognito-idp admin-user-global-sign-out --user-pool-id $USERPOOLID --username gold1

echo 'App Deployment Complete!'
