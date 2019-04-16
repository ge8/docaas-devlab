# SECURING SAAS APPLICAITONS BUILT ON SERVERLESS MICROSERVICES
In this Lab, you'll crack open the IDE to secure a SaaS platform built on a ReactJS web app and NodeJS serverless microservices. The app uses Amazon API Gateway and Amazon Cognito to simplify the operation and security of the service's API and identity functionality. You'll enforce user isolation and data partitioning with OAuth's JWT tokens and IAM conditional policies. You'll also abstract the security complexity from developers to keep operational burden to a minimum, maximizing developer productivity, and maintaining a great developer experience.

# INITIAL SET UP
### AWS Account requirements
* IAM user with admin policy
* A Route53 hosted zone with authoratative domain or subdomain name (labx.docaas.net)
* An AWS ACM certificate in the us-east-1 region for the domain/sudomain name above and *. alias.
* A Private S3 bucket for deployment purposes (SAMBUCKET)
### Machine prerequisites:
* Install VS Code (or IDE of choice)
* Install and configure the AWS CLI with the IAM credentials above and the default region (e.g. ap-southeast-2)
* Two web browsers installed (e.g. Google Chrome and Mozilla Firefox)
### Lab Setup (for Mac users)
* Navigate to desktop folder and clone repo: 
```shell
cd ~/Desktop
git clone https://github.com/ge8/docaas-summit
```
* Set SAMBUCKET (S3 bucket name for deployment), REGION (e.g. ap-southeast-2) and STACK (a name for a cloudformation stack) in the load-variables.sh script.
* Set DomainName (e.g. summit.docaas.net) and AcmCertificateArn as the ACM Certificate ARN created at for the AWS Account requirements above.
* Deploy backend & app: 
```shell
cd docaas-summit 
./deploy-template.sh # Might take from 10 to 40 mins (Cloudfront takes that much)
./deploy-app.sh
```

# LABS
### Lab 0: Check the app out
* Play with the app (labx.docaas.net) by:
** Using an incognito Chrome browser, and login with username: bronze1 password: Permanent1!
** Using an incognito Firefox browser, and login with username: silver1 password: Permanent1!
** Using an incognito Edge browser, and login with username: silver1 password: Permanent1!
* Check out the reactjs app
Open VS Code + 
* Check out SAM template
* Check out CloudFormation resources using the AWS Console.

### Lab 1: Access Control


### Lab 2: Data Partitioning


-------------------------

# TO DO:
## Lab0 to Lab1: Browser Protection + Access Control based on SaaS plan attribute
(Optional) Prove cross access?
No CORS in SAM template & react app. Does it work? -> Lab1: Add CORS to cf and react app.

Prove all customers access it all regardless of plan with Insomnia.
Cognito Access Control in template -> Lab1: Add Lambda Authoriser to SAM template.
Optional while deploy: SAM CLI test Lambda Authoriser.

## Lab1 to Lab2: Data Partitioning + Abstracting Dev Complexity.
(Optional) Prove coding error in Lambda can break any customer
Full Dynamo access in Cognito Auth Role -> Lab2: Add conditional policy.
(OPTIONAL) identity-ids prepended already? Or make it happen by modifying deck access helper?


# Demo 2: Data Partitioning + Abstracting Dev Complexity.
Notice that Deck access helper STILL just writes based on identity-id with Lambda Role.
Modify Lambda Authorizer to return or use Context.
New Policy for Cognito.
Modify Deck-Data Helper to use this!
