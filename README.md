# SECURING SAAS APPLICAITONS BUILT ON SERVERLESS MICROSERVICES
In this Lab, you'll crack open the IDE to secure a SaaS platform built on a ReactJS web app and NodeJS serverless microservices. The app uses Amazon API Gateway and Amazon Cognito to simplify the operation and security of the service's API and identity functionality. You'll enforce user isolation and data partitioning with OAuth's JWT tokens and IAM conditional policies. You'll also abstract the security complexity from developers to keep operational burden to a minimum, maximizing developer productivity, and maintaining a great developer experience.

# INITIAL SET UP
### AWS Account requirements
* IAM user with admin policy and access keys.
* A Route53 hosted zone with a domain e.g. docaas.net. Route 53 name servers should be the authoritative name servers for the domain.
* An AWS ACM certificate in the us-east-1 region for the domain/sudomain name above and *. alias. (The ARN for this ACM Certificate will be later configured as the AcmCertificateArn parameter)
* A Private S3 bucket for deployment purposes (will be later configured as the SAMBUCKET parameter)
### Machine prerequisites (for linux/mac users):
* Install/Update VS Code (or IDE of choice)
* Install/Update Brew [https://brew.sh/]
* Install/Update the AWS CLI with the IAM credentials above and the default region e.g. ap-southeast-2. [https://docs.aws.amazon.com/cli/latest/userguide/install-linux-al2017.html]
* Configure the AWS CLI with the IAM user's access keys, your default region e.g. ap-southeast-2 and json as default output. [https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html]
* Install/Update the AWS SAM CLI [https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/serverless-sam-cli-install-linux.html]
* Two web browsers installed (e.g. Google Chrome and Mozilla Firefox)
### Lab Setup (for linux/mac users)
* Navigate to desktop folder and clone repo: 
```shell
cd ~/Desktop
git clone https://github.com/ge8/docaas-summit
```
* Open the folder ~/Desktop/docaas-summit in VS Code (or your IDE of choice)
* Open load-variables.sh and set SAMBUCKET (S3 bucket name for deployment created aboive), REGION (the same defaul region confifured on the AWS CLI e.g. ap-southeast-2).
![alt text](https://github.com/ge8/docaas-summit/raw/master/frontend/src/images/1.png "Logo Title Text 1")
* Open template.yaml found in the backend directory, and set the parameters: DomainName (e.g. summit.docaas.net) and AcmCertificateArn as the ARN of the ACM Certificate ARN created above.
![alt text](https://github.com/ge8/docaas-summit/raw/master/frontend/src/images/2.png "Logo Title Text 1")
* From the ~/Desktop/docaas-summit directory, deploy the backend & app. This might take from 10 to 40 mins because Cloudfront takes that much (Go grab a cup of tea/coffee or play a Fortnite game while it deploys)
```shell
./deploy-template.sh 
./deploy-app.sh
```
![alt text](https://github.com/ge8/docaas-summit/raw/master/frontend/src/images/3.png "Logo Title Text 1")

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
