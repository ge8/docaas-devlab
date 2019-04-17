# SECURING SAAS APPLICAITONS BUILT ON SERVERLESS MICROSERVICES
In this Lab, you'll crack open the IDE to secure a SaaS platform built on a ReactJS web app and NodeJS serverless microservices. The app uses Amazon API Gateway and Amazon Cognito to simplify the operation and security of the service's API and identity functionality. You'll enforce user isolation and data partitioning with OAuth's JWT tokens and IAM conditional policies. You'll also abstract the security complexity from developers to keep operational burden to a minimum, maximizing developer productivity, and maintaining a great developer experience.

# INITIAL SET UP
### AWS Account requirements
* IAM user with admin policy and access keys.
* A Route53 hosted zone with a domain e.g. docaas.net. Route 53 name servers should be the authoritative name servers for the domain.
* An AWS ACM certificate in the **_us-east-1_** region for the domain/sudomain name above and *. alias. (The ARN for this ACM Certificate will be later configured as the **_AcmCertificateArn_** parameter)
* A Private S3 bucket for deployment purposes (will be later configured as the **_SAMBUCKET_** parameter)
### Machine prerequisites (for linux/mac users):
* Install/Update VS Code (or IDE of choice)
* Install/Update Brew <a href="https://brew.sh/" target="_blank">Link</a>
* Install/Update the AWS CLI with the IAM credentials above and the default region e.g. **_ap-southeast-2_**. <a href="https://docs.aws.amazon.com/cli/latest/userguide/install-linux-al2017.html" target="_blank" style="width:50%;height:auto;">Link</a>
* Configure the AWS CLI with the IAM user's access keys, your default region e.g. **_ap-southeast-2_** and **_json_** as default output. <a href="https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html" target="_blank" style="width:10%;height:auto;">Link</a>
* Install/Update the AWS SAM CLI <a href="https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/serverless-sam-cli-install-linux.html" target="_blank">Link</a>
* Three web browsers installed e.g. Google Chrome, Mozilla Firefox, and Safari or Edge
### Lab Setup (for linux/mac users)
* Navigate to desktop folder and clone repo: 
```shell
cd ~/Desktop
git clone https://github.com/ge8/docaas-summit
```
* Open the folder **_~/Desktop/docaas-summit_** in VS Code (or your IDE of choice)
* Open **_load-variables.sh_** and set **_SAMBUCKET_** (S3 bucket name for deployment created above), **_REGION_** (the same default region configured on the AWS CLI e.g. **_ap-southeast-2_**).
<img src="https://github.com/ge8/docaas-summit/raw/master/frontend/src/images/1.png" width="50%">

* Open **_template.yaml_** found in the **_backend_** directory, and set the parameters:  
1. **_DomainName_** as an non-existing subdomain for your domain above e.g. lab.docaas.net. You **_don't_** need to create a Route 53 record for this subdomain because the setup scripts below will create it for you.
2. **_AcmCertificateArn_** as the ARN of the ACM Certificate ARN created above.
<img src="https://github.com/ge8/docaas-summit/raw/master/frontend/src/images/2.png" width="80%">

* From the ~/Desktop/docaas-summit directory, deploy the backend & app. This might take from 10 to 40 mins because Cloudfront takes that much (Go grab a cup of tea/coffee or play a Fortnite game while it deploys)
```shell
./deploy-template.sh 
./deploy-app.sh
```
<img src="https://github.com/ge8/docaas-summit/raw/master/frontend/src/images/3.png" width="50%">

# LABS 
### Lab 0: Check the app out
Deck Of Cards as a Service is an online service that allows users to create virtual decks of cards, shuffle decks, deal 2-card games, etc. We have three user plans:

<img src="https://github.com/ge8/docaas-summit/raw/master/frontend/src/images/plans.png" width="30%">

1. Login into the app with three different users (gold1, silver1 and bronze1) by going to your DomainName using incognito browser sessions on three different browsers (this prevent caching issues with ReactJS). You will be prompted to change the password for a permanent one e.g. Permanent1!. For example:
*  Chrome, username: gold1, password: Temporary1! (Use Chrome for the gold1 user - you'll need this below)
*  Firefox, username: silver1, password: Temporary1!
*  Safari/Edge, username: bronze1, password: Temporary1!
<img src="https://github.com/ge8/docaas-summit/raw/master/frontend/src/images/entry.png" width="50%">

2. With some users, **_create_** and **_get_** a couple of decks. You need to type a deck name or number in the text field e.g. "111". Note: the first time you execute an AWS Lambda function, it
<img src="https://github.com/ge8/docaas-summit/raw/master/frontend/src/images/create111.png" width="45%"> <img src="https://github.com/ge8/docaas-summit/raw/master/frontend/src/images/get111.png" width="44%">

3. With some users, play a few **_games_**. Note that this 2-card game with perfectly ordered decks, makes no sense.
<img src="https://github.com/ge8/docaas-summit/raw/master/frontend/src/images/game111.png" width="50%">

4. With some users, **_shuffle_** a few decks and then **_get_** them and play **_games_** with the shuffled deck.
<img src="https://github.com/ge8/docaas-summit/raw/master/frontend/src/images/shuffle111.png" width="50%">

* Note the Cut service won't work because it's misconfigured and you'll fix it as part of Lab 1.

5. Using the app in the Chrome browser loges in as the gold user, open **_Developer Tools_** by either going to the Chrome menu > More Tools > Developer Tools (or simply using the keyboard shortcut: command+options+I). Go to the console tab and then try to **_cut_** a deck. You'll notice this fails and gives you a CORS error in the console. This is what happens when CORS isn't configured in your API: the browser will prevent you from accessing the API.
<img src="https://github.com/ge8/docaas-summit/raw/master/frontend/src/images/cut-error.png" width="80%">

6. At the top of the console logs, you'll see a long string of seemilgly random characters. This is the user's identity token - it's one of the three JWT tokens <a href="https://en.wikipedia.org/wiki/JSON_Web_Token" target="_blank">Link</a> as part of the OAuth standard <a href="https://en.wikipedia.org/wiki/OAuth" target="_blank">Link</a>  which is used by Open ID Connect <a href="https://en.wikipedia.org/wiki/OpenID_Connect" target="_blank">Link</a>identity providers like Amazon Cognito for our app. 

Let's inspect this JWT token. Copy this token by copying it and pasting it at [https://jwt.io/].
<img src="https://github.com/ge8/docaas-summit/raw/master/frontend/src/images/jwtio.png" width="70%">

Note that the token's signature is valid. 

The payload of the identity token contains the meat of the token. You can add as many claims in payload as you want, such as **_iss_** (the identity provider that validated the token), **_cognito:username_**, **_email_**, etc. For SaaS apps, things like subscription status, or plan can be useful. The way you add more fields with Amazon Cognito is by creating custom attributes like we did with (**_custom:plan_**)

This flexibility makes Open ID Connect and SaaS apps are a great match because it’s a lightweight and secure way all you microservices can get user context without having to pull information from different places.

On Lab 1, we will use the **_custom:plan_** found in the JWT token to control access to API resources.

7. Check out the ReactJS source code found in the **_frontend_** directory.

8. Check out the backend source code found in the **_backend_** directory. 
* Note there are 9 AWS Lambda functions written in NodeJS - these are the 7 microservices that serve our app, plus 2 Lambda functions for CORS and Lambda Authorizer (not in use yet)
<img src="https://github.com/ge8/docaas-summit/raw/master/frontend/src/images/microservices.png" width="80%">

* Check out SAM template called **_template.yaml_** found in the **_backend_** directory and see all the resources that are part of the CloudFormation stack.
<img src="https://github.com/ge8/docaas-summit/raw/master/frontend/src/images/architecture.png" width="80%">


### Lab 1: Access Control
In this Lab, you'll improve the Access Control configuration of the application in two areas: CORS (Cross-Origin Resource Sharing) and Access Control to API resources.

#### CORS
Cross-Origin Resource Sharing <a href="https://en.wikipedia.org/wiki/Cross-origin_resource_sharing" target="_blank">Link</a> is a security standard measure that needs to be implemented in some APIs in order to let web browsers access them. The implication of having of this misconfigured can be anywhere having data stolen to having our entire application compromised. With CORS, browsers send an ***_options_** request to the API - and the API responds with permissions.

At the moment our application is proxing these options requests to a CORS-specific Lambda function and the Lambda response is hardcoded with a wildcard for origin that allows any computer in the world to access the APIs. We'll improve this in two ways: 1) Replacing the CORS Lambda function with Amazon API Gateway native support for CORS <a href="https://docs.aws.amazon.com/apigateway/latest/developerguide/how-to-cors.html" target="_blank">Link</a>. This way we won't have to have a Lambda function for this. 2) Restricting origin permissions to our Subdomain name. Let's do it!

1. Check out the CORS Lambda function definition in the SAM template **_template.yaml_** found in the **_backend_** directory. The syntax used here is part of the Serverless Appication Model (SAM) <a href="https://aws.amazon.com/serverless/sam/" target="_blank">Link</a> which makes it easier to create, manage and update Serverless resources like AWS Lambda functions, Amazon API Gateway APIs and Amazon DynamoDB tables.
<img src="https://github.com/ge8/docaas-summit/raw/master/frontend/src/images/old-cors-template.png" width="70%">

2. Check out the CORS Lambda function code **_cors.js_** found in the **_backend/src_** directory. Note that by having a wildcard '*', this API can be accessed by any origin from the interwebs.
<img src="https://github.com/ge8/docaas-summit/raw/master/frontend/src/images/old-cors-lambda.png" width="70%">

Let's replace the CORS Lambda function with Amazon API Gateway native support for CORS.

3. Open the SAM template **_template.yaml_** found in the **_backend_** directory. First, hide or remove the CORS Lambda function definition. 
<img src="https://github.com/ge8/docaas-summit/raw/master/frontend/src/images/old-cors-template-hidden.png" width="70%">

Then, reconfigure each of the 4 **_options_** methods (Create, Get, Game, Shuffle) found in the API Gateway Resources to use the MOCK type instead of the AWS_PROXY type. You can do this by simply hiding and unhiding the relevant sections of the template. Note that the new mocked CORS responses are only allowing the origin to be our subdomain.
<img src="https://github.com/ge8/docaas-summit/raw/master/frontend/src/images/options-method-cors.png" width="70%">

Then, enable the entire **_options_** method definition for the **_Cut_** resource found last in the API Gateway Resources. 
<img src="https://github.com/ge8/docaas-summit/raw/master/frontend/src/images/options-method-cut.png" width="70%">

4. Now you can remove the **_cors.js_** file from **_backend/src_**

CORS configuration is now properly congifured but before deploying changes, we'll improve the access control to API resources.

#### Access Control to API resources
API Gateway supports multiple mechanisms for controlling access to your API <a href="https://docs.aws.amazon.com/apigateway/latest/developerguide/apigateway-control-access-to-api.html" target="_blank">Link</a>. At the moment we have our Cognito User Pool configured as the Authorizer. Although this is easy and completely managed by Cognito and API Gateway, it only allows a binary check: if the JWT tokens are valid (user is loged in), then it allows access to **_ALL_** API resources. A better approach would be to allow granular access to API resources based on the user plans. For example: silver users shouldn’t be able to access the Cut service. While Bronze users should only be able to access Create, Get and Game.

So, we're going to swap the authorizer from Cognito User Pool to a Lambda Authorizer. A Lambda Authorizer is an authorization option for API Gateway that allows us to inspect bearer token authentication methods (such as SAML or OAuth) and make access control decisions based on that.
<img src="https://github.com/ge8/docaas-summit/raw/master/frontend/src/images/lambda-authorizer.png" width="70%">

This is how it works: API Gateway calls the Lambda function and supplies the JWT Tokens. The Lambda Authorizer runs your code (in this case we'll validate the JWT token and make access control decisions based on the custom:plan coming in the token's payload). Tha Lambda Authorizer returns the IAM policies that authorize that specific tokenalong with some context. If the returned policy is invalid or the permissions are denied, the API call does not succeed. For a valid policy, API Gateway caches the returned policy, associated with the incoming token  over a configurable TTL. For allowed calls, API gateway embeds the context to downstream services. 

Additionally, we'll use the context created by the Lambda Authorizer to embed all user information that our downstream microservices need in order operate without having to validate tokens or pull info from services like Amazon Cognito. This way we're abstracting the security complexity and maintaing a good developer experience from microservices developers.

1. (Optional) use an REST client like Insomnia [https://insomnia.rest/] to see how the silver1 and the bronze1 users (using custom:plan=silver and custom:plan=bronze respectively) can access the **_Cut_** API resouce - which shouldn't be the case. Make sure you use the user's JWT token in the Authorization header
<img src="https://github.com/ge8/docaas-summit/raw/master/frontend/src/images/insomnia-1.png" width="70%">

2. Open the SAM template **_template.yaml_** found in the **_backend_** directory and let's replace the AWS::ApiGateway::Authorizer type from Cognito User Pools to **_Token_** (this is a Lambda Authorizer). You can do this by simply hiding and unhiding the relevant sections of the template.
<img src="https://github.com/ge8/docaas-summit/raw/master/frontend/src/images/template-authorizer.png" width="70%">

3. Define the Lambda Authoriser Lambda function using SAM syntax and its permissions. You can do this by simply hiding and unhiding the relevant sections of the template.
<img src="https://github.com/ge8/docaas-summit/raw/master/frontend/src/images/template-lambda-authorizer.png" width="70%">

4. Finally we need to update the **_AuthorizationType_** for all 5 of our POST or GET methods so that they stop using Cognito (**_COGNITO_USER_POOLS_**) and start using our Lambda Authorizer (**_CUSTOM_**)
<img src="https://github.com/ge8/docaas-summit/raw/master/frontend/src/images/authorization-type.png" width="70%">

Now we're ready to deploy all changes! This should take about 1 minute.
```shell
cd ~/Desktop
./update-template.yaml
```

5. Check out the app and confirm everything is working.

6. (Optional) use an REST client like Insomnia [https://insomnia.rest/] to see how the silver1 and the bronze1 users (using custom:plan=silver and custom:plan=bronze respectively) are now blocked from accessing the **_Cut_** API resouce thanks to the fine grained access control we implemented.
<img src="https://github.com/ge8/docaas-summit/raw/master/frontend/src/images/insomnia-2.png" width="70%">


### Lab 2: Data Partitioning


### How to reset the demo
You can reset the demo by running the following:
```
cd ~/Desktop
git 

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
