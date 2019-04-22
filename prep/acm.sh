#!/bin/bash

. ./load-variables.sh

aws configure set default.region us-east-1

CERTARN=`aws acm request-certificate --domain-name $DOMAIN --validation-method DNS | jq --raw-output '.CertificateArn'`
echo $CERTARN
sleep 15

DOMAINNAME1=`aws acm describe-certificate --certificate-arn $CERTARN | jq --raw-output '.Certificate.DomainValidationOptions[0].DomainName'`
NAMECNAME1=`aws acm describe-certificate --certificate-arn $CERTARN | jq --raw-output '.Certificate.DomainValidationOptions[0].ResourceRecord.Name'`
VALUECNAME1=`aws acm describe-certificate --certificate-arn $CERTARN | jq --raw-output '.Certificate.DomainValidationOptions[0].ResourceRecord.Value'`
echo $DOMAINNAME1
echo $NAMECNAME1
echo $VALUECNAME1

ZONEID=`aws route53 list-hosted-zones-by-name --dns-name $DOMAIN | jq --raw-output '.HostedZones[0].Id'`
echo "ZONEID is $ZONEID"
cd prep
cp r53acm.json r53acm-mod.json
find r53acm-mod.json -type f -exec sed -i -e "s/##TARGETGOESHERE##/$VALUECNAME1/g" {} \;
rm -f r53acm-mod.json-e 
find r53acm-mod.json -type f -exec sed -i -e "s/##DOMAINGOESHERE##/$NAMECNAME1/g" {} \;
rm -f r53acm-mod.json-e 
aws route53 change-resource-record-sets --hosted-zone-id $ZONEID --change-batch file://r53acm-mod.json
rm -f r53acm-mod.json
cd ..

echo "waiting for ACM validation for $CERTARN"
aws acm wait certificate-validated --certificate-arn $CERTARN
aws configure set default.region $REGION
echo 'Validation Done!'






# Modify default DomainName in template.yaml 
ACCOUNT=$(aws sts get-caller-identity --output text --query 'Account')
TAIL="docaas-devlab"
export SAMBUCKET="$ACCOUNT-$TAIL"

# Modify default AcmCertificateArn in template.yaml from docaas-devlab-prep2 output


