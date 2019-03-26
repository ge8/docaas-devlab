# AWS Account requirements
IAM user with admin policy
A Route53 hosted zone with authoratative domain or subdomain name (labx.docaas.net)
An AWS ACM certificate in the us-east-1 region for the domain/sudomain name above and *. alias.
A Private S3 bucket for deployment purposes (SAMBUCKET)

# Machine prerequisites:
Install VS Code.
Install and configure AWS CLI with the IAM credentials above and the default region (ap-southeast-2.)
Google Chrome, Mozilla Firefox and Microsoft Edge - all installed.

# Lab Setup
Navigate to desktop folder and clone repo: 
```shell
cd ~/Desktop
git clone https://github.com/ge8/docaas-summit
```
Set SAMBUCKET (S3 bucket name for deployment), REGION (ap-southeast-2) and STACK (name for cloudformation stack) in load-variables.sh script.
Set DomainName (summit.docaas.net) and AcmCertificateArn (created for AWS Account requirements above) in backend/template.yml parameters.
Deploy backend & app: 
```shell
cd docaas-summit 
./deploy-template.sh #Might take up to 30 min 
./deploy-app.sh
```

# Verify app deployment
Using an incognito browser, go to your domain (labx.docaas.net).

Login with bronze1, password: Temporary1! 
Set new password to Permanent!
Create a couple of decks, get the decks, play games with the decks.

Login with silver1, password: Temporary1! 
Set new password to Permanent!
Create a couple of decks, get the decks, play games with the decks, shuffle the decks.

Login with gold1, password: Temporary1! 
Set new password to Permanent!
Create a couple of decks, get the decks, play games with the decks, shuffle the decks, cut the decks.