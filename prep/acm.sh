#!/bin/bash

. ./load-variables.sh

CERTARN=`aws acm request-certificate --domain-name $DOMAIN --validation-method DNS --region us-east-1 --query 'CertificateArn' --output text`
echo $CERTARN
sleep 15

DOMAINNAME1=`aws acm describe-certificate --certificate-arn $CERTARN --region us-east-1 --query 'Certificate.DomainValidationOptions[0].DomainName' --output text`
NAMECNAME1=`aws acm describe-certificate --certificate-arn $CERTARN --region us-east-1 --query 'Certificate.DomainValidationOptions[0].ResourceRecord.Name' --output text`
VALUECNAME1=`aws acm describe-certificate --certificate-arn $CERTARN --region us-east-1 --query 'Certificate.DomainValidationOptions[0].ResourceRecord.Value' --output text`
echo $DOMAINNAME1
echo $NAMECNAME1
echo $VALUECNAME1

ZONEID=$(aws route53 list-hosted-zones-by-name --dns-name $DOMAIN --query 'HostedZones[0].Id' --output text)
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
aws acm wait certificate-validated --certificate-arn $CERTARN --region us-east-1
echo 'Validation Done!'


# Modify default DomainName in template.yaml 
find backend/template.yaml -type f -exec sed -i -e "s/summit.docaas.net/$DOMAIN/g" {} \;
rm -f backend/template.yaml-e 

# Modify default AcmCertificateArn in template.yaml from docaas-devlab-prep2 output
find backend/template.yaml -type f -exec sed -i -e "s#arn:aws:acm:us-east-1:385251132543:certificate/d79fe14c-ca45-473e-99ce-451921703e86#$CERTARN#g" {} \;
rm -f backend/template.yaml-e 


