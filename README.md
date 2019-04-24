<img src="https://github.com/ge8/docaas-devlab/raw/master/frontend/src/images/AWS-logo.png" width="20%">

# DEVLAB: SECURING SAAS APPLICATIONS BUILT ON SERVERLESS MICROSERVICES - Level 400
In this DevLab, you'll crack open the IDE to secure a SaaS platform built on a ReactJS web app and NodeJS serverless microservices. The app uses Amazon API Gateway and Amazon Cognito to simplify the operation and security of the service's API and identity functionality. You'll enforce user isolation and data partitioning with OAuth's JWT tokens and IAM conditional policies. You'll also abstract the security complexity from developers to keep operational burden to a minimum, maximizing developer productivity, and maintaining a great developer experience.

# LABS 
### Lab 0: Check the app out at **_YourAWSAccount_.docaas.net**
Your app's public url is **_YourAWSAccount_.docaas.net**. You need to replace **_YourAWSAccount_** with the number of the AWS account you're using without any dashes. You can find the AWS account you are using on the top right corner of the AWS console, under my account (for example, if the AWS account assigned to your laptop is 7283-2085-8977, your app would be located at 728320858977.docaas.net)

<img src="https://github.com/ge8/docaas-devlab/raw/master/frontend/src/images/account.png" width="70%">

##### DoCaaS
**Deck Of Cards as a Service** is an online service that allows users to create virtual decks of cards, shuffle decks, deal 2-card games, etc. We have three user plans:

<img src="https://github.com/ge8/docaas-devlab/raw/master/frontend/src/images/plans.png" width="30%">

1. Login into the app with three different users (gold1, silver1 and bronze1) by going to your app's url (**_YourAWSAccount_.docaas.net**) using incognito browser sessions on three different browsers (this prevent caching issues with ReactJS).
*  Chrome, username: gold1, password: Permanent1! (Use Chrome for the gold1 user - you'll need this below)
*  Firefox, username: silver1, password: Permanent1!
*  Safari/Edge, username: bronze1, password: Permanent1!
<img src="https://github.com/ge8/docaas-devlab/raw/master/frontend/src/images/entry.png" width="50%">

2. With some users, **_create_** and **_get_** a couple of decks. You need to type a deck name or number in the text field e.g. "111". 

Note: the first time you execute an AWS Lambda function, you may experience a couple of seconds of delay - this is called a "cold start". This only occurs the first time you use a Lambda function after creation, update or after a long period without use. For this app, a single "create" may cold-start up to 3 lambda functions, so you might need to way up to 10 seconds the first time to execute these functions. This lab doesn't intend to resolve cold starts. This is a great advanced re:Invent session that explains cold-starts and how to optimise your set up [https://www.youtube.com/watch?v=oQFORsso2go]

Some of the application functions, hit multiple lambdas in sequence, if they're all cold, you might expeci
<img src="https://github.com/ge8/docaas-devlab/raw/master/frontend/src/images/create111.png" width="45%"> <img src="https://github.com/ge8/docaas-devlab/raw/master/frontend/src/images/get111.png" width="44%">

3. With some users, play a few **_games_**. Note that this 2-card game with perfectly ordered decks, makes no sense.
<img src="https://github.com/ge8/docaas-devlab/raw/master/frontend/src/images/game111.png" width="50%">

4. With some users, **_shuffle_** a few decks and then **_get_** them and play **_games_** with the shuffled deck.
<img src="https://github.com/ge8/docaas-devlab/raw/master/frontend/src/images/shuffle111.png" width="50%">

* Note the Cut service won't work because it's misconfigured and you'll fix it as part of Lab 1.

5. Using the app browser logged in as the gold user, open **_Developer Tools_**. In Chrome, you do this by either going to the Chrome menu > More Tools > Developer Tools (or simply using the keyboard shortcut: command+options+I). Go to the console tab and then try to **_cut_** a deck. You'll notice this fails and gives you a CORS error in the console. This is what happens when CORS isn't configured in your API: the browser will prevent you from accessing the API.
<img src="https://github.com/ge8/docaas-devlab/raw/master/frontend/src/images/cut-error.png" width="80%">

6. At the top of the console logs, you'll see a long string of seemilgly random characters. This is the user's identity token - it's one of the three JWT tokens <a href="https://en.wikipedia.org/wiki/JSON_Web_Token" target="_blank">Link</a> as part of the OAuth standard <a href="https://en.wikipedia.org/wiki/OAuth" target="_blank">Link</a>  which is used by Open ID Connect <a href="https://en.wikipedia.org/wiki/OpenID_Connect" target="_blank">Link</a> identity providers like Amazon Cognito for our app. 

Let's inspect this JWT token. Copy this token by copying it and pasting it at [https://jwt.io/].
<img src="https://github.com/ge8/docaas-devlab/raw/master/frontend/src/images/jwtio.png" width="70%">

Note that the token's signature is valid. 

The payload of the identity token contains the meat of the token. You can add as many claims in payload as you want, such as **_iss_** (the identity provider that validated the token), **_cognito:username_**, **_email_**, etc. For SaaS apps, things like subscription status, or plan can be useful. The way you add more fields with Amazon Cognito is by creating custom attributes like we did with **_custom:plan_**.

This flexibility makes Open ID Connect identity providers like Amazon Cognito and SaaS apps are a great match because you get a lightweight and secure way all you microservices can get user context without having to pull information from different places.

On Lab 1, we will use the **_custom:plan_** found in the JWT token to control access to API resources.

7. Check out the ReactJS source code found in the **_frontend_** directory.

8. Check out the backend source code found in the **_backend_** directory. 
* Note there are 9 AWS Lambda functions written in NodeJS - 7 of those are part of the microservices that serve our app, plus 2 Lambda functions for CORS and Lambda Authorizer (not in use yet - you'll use it in Lab 1)
<img src="https://github.com/ge8/docaas-devlab/raw/master/frontend/src/images/microservices.png" width="80%">

* Check out the SAM template called **_template.yaml_** found in the **_backend_** directory and see all the resources that are part of the CloudFormation stack.
<img src="https://github.com/ge8/docaas-devlab/raw/master/frontend/src/images/architecture.png" width="80%">


### Lab 1: Access Control
In this Lab, you'll improve the Access Control configuration of the application in two areas: CORS (Cross-Origin Resource Sharing) and Access Control to API resources.

#### CORS
Cross-Origin Resource Sharing <a href="https://en.wikipedia.org/wiki/Cross-origin_resource_sharing" target="_blank">Link</a> is a security standard measure that needs to be implemented in some APIs in order to let web browsers access them. The implication of having of this misconfigured can be anywhere from having data stolen to having our entire application compromised. With CORS, browsers send an ***_options_** request to the API - and the API responds with permissions.

At the moment our application is proxing these options requests to a CORS-specific Lambda function and the Lambda response is hardcoded with a wildcard for origin that allows any computer in the world to access the APIs. We'll improve this in two ways: 1) Replacing the CORS Lambda function with Amazon API Gateway native support for CORS <a href="https://docs.aws.amazon.com/apigateway/latest/developerguide/how-to-cors.html" target="_blank">Link</a>. This way we won't have to have a Lambda function for this. 2) Restricting origin permissions to our Subdomain name. Let's do it!

1. Check out the CORS Lambda function definition in the SAM template **_template.yaml_** found in the **_backend_** directory. The syntax used here is part of the Serverless Appication Model (SAM) <a href="https://aws.amazon.com/serverless/sam/" target="_blank">Link</a> which makes it easier to create, manage and update Serverless resources like AWS Lambda functions, Amazon API Gateway APIs and Amazon DynamoDB tables.
<img src="https://github.com/ge8/docaas-devlab/raw/master/frontend/src/images/old-cors-template.png" width="70%">

2. Check out the CORS Lambda function code **_cors.js_** found in the **_backend/src_** directory. Note that by having a wildcard '*', this API can be accessed by any origin from the interwebs.
<img src="https://github.com/ge8/docaas-devlab/raw/master/frontend/src/images/old-cors-lambda.png" width="70%">

Let's replace the CORS Lambda function with Amazon API Gateway native support for CORS.

3. Open the SAM template **_template.yaml_** found in the **_backend_** directory. First, hide or remove the CORS Lambda function definition. 
<img src="https://github.com/ge8/docaas-devlab/raw/master/frontend/src/images/old-cors-template-hidden.png" width="70%">

Then, reconfigure each of the 4 **_options_** methods (Create, Get, Game, Shuffle) found in the API Gateway Resources to use the MOCK type instead of the AWS_PROXY type. You can do this by simply hiding and unhiding the relevant sections of the template. Note that the new mocked CORS responses are only allowing the origin to be our subdomain.
<img src="https://github.com/ge8/docaas-devlab/raw/master/frontend/src/images/options-method-cors.png" width="70%">

Then, enable the entire **_options_** method definition for the **_Cut_** resource found last in the API Gateway Resources. 
<img src="https://github.com/ge8/docaas-devlab/raw/master/frontend/src/images/options-method-cut.png" width="70%">

4. Now you can remove the **_cors.js_** file from **_backend/src_**

CORS configuration is now properly congifured but before deploying changes, we'll improve the access control to API resources.

#### Access Control to API resources
API Gateway supports multiple mechanisms for controlling access to your API <a href="https://docs.aws.amazon.com/apigateway/latest/developerguide/apigateway-control-access-to-api.html" target="_blank">Link</a>. At the moment we have our Cognito User Pool configured as the Authorizer. Although this is easy and completely managed by Cognito and API Gateway, it only allows a binary check: if the JWT tokens are valid (user is logged in), then it allows access to **_ALL_** API resources. A better approach would be to allow granular access to API resources based on the user plans. For example: silver users shouldn’t be able to access the Cut service. While Bronze users should only be able to access Create, Get and Game.

So, we're going to swap the authorizer from Cognito User Pool to a Lambda Authorizer. A Lambda Authorizer is an authorization option for API Gateway that allows us to inspect bearer token authentication methods (such as SAML or OAuth) and make access control decisions based on that.
<img src="https://github.com/ge8/docaas-devlab/raw/master/frontend/src/images/lambda-authorizer.png" width="70%">

This is how it works: API Gateway calls the Lambda function and supplies the JWT Tokens. The Lambda Authorizer runs your code (in this case we'll validate the JWT token and make access control decisions based on the custom:plan coming in the token's payload). Tha Lambda Authorizer returns the IAM policies that authorize that specific tokenalong with some context. If the returned policy is invalid or the permissions are denied, the API call does not succeed. For a valid policy, API Gateway caches the returned policy, associated with the incoming token  over a configurable TTL. For allowed calls, API gateway embeds the context to downstream services. 

Additionally, we'll use the context created by the Lambda Authorizer to embed all user information that our downstream microservices need in order operate without having to validate tokens or pull info from services like Amazon Cognito. This way we're abstracting the security complexity and maintaing a good developer experience from microservices developers.

1. (Optional) use an REST client like Insomnia [https://insomnia.rest/] to see how the silver1 and the bronze1 users (using custom:plan=silver and custom:plan=bronze respectively) can access the **_Cut_** API resouce - which shouldn't be the case. Make sure you use the user's JWT token in the Authorization header
<img src="https://github.com/ge8/docaas-devlab/raw/master/frontend/src/images/insomnia-1.png" width="70%">

2. Inspect the Lambda Authorizer code **_authoriser.js_** found in **_backend/src_**. This function is quite long. Note what we're doing in the three main parts of the handler **exports.authorise_request**: 1) Validating the JWT token. 2) Constructing the **_IAM Policy_** for the JWT token. 3) Constructing the **_context_** of the token.

3. Open the SAM template **_template.yaml_** found in the **_backend_** directory and let's replace the AWS::ApiGateway::Authorizer type from Cognito User Pools to **_Token_** (this is a Lambda Authorizer). You can do this by simply hiding and unhiding the relevant sections of the template.
<img src="https://github.com/ge8/docaas-devlab/raw/master/frontend/src/images/template-authorizer.png" width="70%">

4. Define the Lambda Authoriser Lambda function using SAM syntax and its permissions. You can do this by simply hiding and unhiding the relevant sections of the template.
<img src="https://github.com/ge8/docaas-devlab/raw/master/frontend/src/images/template-lambda-authorizer.png" width="70%">

5. Finally we need to update the **_AuthorizationType_** for all 5 of our POST or GET methods so that they stop using Cognito (**_COGNITO_USER_POOLS_**) and start using our Lambda Authorizer (**_CUSTOM_**)
<img src="https://github.com/ge8/docaas-devlab/raw/master/frontend/src/images/authorization-type.png" width="70%">

6. Now we're ready to deploy all changes! This should take about 1 minute.
```shell
cd ~/environment/docaas-devlab
./update-template.yaml
```

7. Check out the app and confirm everything is working.

8. (Optional) use an REST client like Insomnia [https://insomnia.rest/] to see how the silver1 and the bronze1 users (using custom:plan=silver and custom:plan=bronze respectively) are now blocked from accessing the **_Cut_** API resouce thanks to the fine grained access control we implemented.
<img src="https://github.com/ge8/docaas-devlab/raw/master/frontend/src/images/insomnia-2.png" width="70%">


### Lab 2: Data Partitioning
Now that Access Control is more secure, we want to secure access to our data. But, where is all our data? We have two independent data stores: one storing all users’ **_decks_** and one storing all users’ **__scores__**.

When you think about it, anyone with rightful access to these DynamoDB tables, could access anyone’s decks or scores. This is not great. For our use case of decks and scores, this doesn't sound too bad, but for a different use case you can be storing more sensitive information such as health information or financial records. Either way it's a best practice to only allow users access to their own items in DynamoDB and nothing else.

We'll fix this by implementing two things: 
1) A composite-key strategy in our DynamoDB tables by prepending all items partition keys are prepended with the Cognito Identity user ID (userid). This help identify which user owns which item.
<img src="https://github.com/ge8/docaas-devlab/raw/master/frontend/src/images/prepended.png" width="40%">

2) A nifty security feature by IAM that allows to have fine-grained access control to DynamoDB tables using conditions on IAM policies based on the key access patterns for DynamoDB. <a href="https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/specifying-conditions.html" target="_blank" style="width:50%;height:auto;">Link</a>. In our case, we'll allow conditional access to items that are prepended with the user's own Cognito Identity ID.
<img src="https://github.com/ge8/docaas-devlab/raw/master/frontend/src/images/policy.png" width="70%">

Let's do it!

1. Go to the AWS Console > DynamoDB > Tables and check out the structure for both the **_decks-master_** and **_scores-master_** tables. You'll notice on the Items tab that both tables are key value stores where the partition key is called **_id_** and is currently the number/name for the decks.
<img src="https://github.com/ge8/docaas-devlab/raw/master/frontend/src/images/table-start.png" width="70%">

2. Go to the AWS Console > IAM > Roles and serch for _"CognitoAuthorized"_. You'll find the Cognito Authorized Role. This is the role given to all authorized users. You'll notice this role has a single IAM policy attached granting full access to DynamoDB. Not great.
<img src="https://github.com/ge8/docaas-devlab/raw/master/frontend/src/images/role-start.png" width="70%">

Let's fix it. First, let's remove the full access to DynamoDB and add our conditional policy to the Cognito Authorized role. 

3. Open the SAM template **_template.yaml_** found in the **_backend_** directory and let's delete/hide the **_- "dynamodb:*"_** line found on the policy of the **_CognitoAuthorizedRole_** resource.
<img src="https://github.com/ge8/docaas-devlab/raw/master/frontend/src/images/full-dynamo-template.png" width="70%">

4. On the same **_CognitoAuthorizedRole_** resource definition, add the conditional policy discussed before. You can do this by simply unhiding the relevant policy. 
<img src="https://github.com/ge8/docaas-devlab/raw/master/frontend/src/images/policy-end.png" width="70%">

We need to make a couple of changes in our Lambda code to ensure the Cognito Identity ID will now be prepended to every read and write to both DynamoDB tables. This functionality is located in two libraries that our datastore microservices lambda use: one for the decks table and one for scores table.

5. Open the library **_deck-dataAccess.js_** found at **_backend/src/common_**. Append the **_tenantID + "-"_** to both the create and read operations: initDeck() and getDeck(). You can do this by simply hiding and unhiding the relevant sections of the code: hide lines 29 and 45; unhide lines 30 and 46.
<img src="https://github.com/ge8/docaas-devlab/raw/master/frontend/src/images/data-access-js.png" width="70%">

6. Do the same as before with **_deck-dataAccess.js_** found at **_backend/src/common_**. You can do this by simply hiding and unhiding the relevant sections of the code: hide lines 7 and 33; unhide lines 6 and 32.

Now our Lambdas will be reading and writing items at **_decks-master_** and **_scores-master-** with the Cognito intentity ID prepended to the partition key!

7. Now we're ready to deploy all changes! This should take about 1 minute.
```shell
cd ~/environment/docaas-devlab
./update-template.yaml
```

8. (Optional) Check out what's inside the **_./update-template.sh_** script found in the project root. 

You'll notice we're using the SAM CLI <a href="https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/serverless-sam-reference.html#serverless-sam-cli" target="_blank" style="width:50%;height:auto;">Link</a>: a command line tool that operates on an AWS SAM template and application code. With the AWS SAM CLI, you can invoke Lambda functions locally, create a deployment package for your serverless application, deploy your serverless application to the AWS Cloud, and so on. In this case, we're only using it to **_package_** and **_deploy_**. These two commands combined package all the artifacts for your CloudFormation stack and your Lambda code, uploads them to S3 and then triggers an update to your CloudFormation stack effectively updating both your Stack and your Lambda functions with only 2 commands! 

One thing that the SAM CLI doesn't do yet with these two commands (feature request) is updating the API stage, so our **_./update-template.sh_** script does precicely that at the end of the script.

9. Play with the app in the browser. Make sure to at least **_create_** a deck and play a **_game_**. Notice the notification after creating the deck that now includes a much longer name.
<img src="https://github.com/ge8/docaas-devlab/raw/master/frontend/src/images/long-name.png" width="70%">

10. Go to the AWS Console > DynamoDB > Tables and check out the recently created items in both the **_decks-master_** and **_scores-master_** tables. You'll notice on the partition key **_id_** is much longer because it now includes the user's Cognito Identity ID prepended.
<img src="https://github.com/ge8/docaas-devlab/raw/master/frontend/src/images/table-end.png" width="70%">

11. Go to the AWS Console > IAM > Roles and serch for _"CognitoAuthorized"_. You'll find the Cognito Authorized Role. This is the role given to all authorized users. You'll notice this role now has a two IAM policies attached. The first one no longer grants access to DynamoDB. The second one is our conditional IAM policy that will only allow users to access their own items on the DynamoDB tables.
<img src="https://github.com/ge8/docaas-devlab/raw/master/frontend/src/images/role-end.png" width="70%">

Congratulations! You've significantly improved the security of our SaaS app by properly implementing access control and data partitioning. You've also abstracted the security complexity from microservice developers. This way developers can stay focused on shipping great quality software fast. **You've now finished the Lab!**

12. Please reset the lab to allow others to use it =)
```
cd ~/environment/docaas-devlab
git reset --hard HEAD && git clean --force -d
git checkout master
./reset-lab.sh
```

<img src="https://github.com/ge8/docaas-devlab/raw/master/frontend/src/images/AWS-logo.png" width="20%">

### Lab Solutions
If you get stuck or want to see or deploy the lab answers, we have those pre-configured in separate branches.

To view the soltion to Lab 1 (and discard all your changes):
```
git reset --hard HEAD && git clean --force -d
git checkout demo1
```
To view the soltion to Lab 2 (and discard all your changes):
```
git reset --hard HEAD && git clean --force -d
git checkout demo2
```
To deploy either of these solutions, simply run the update-template.sh command.
```
cd ~/environment/docaas-devlab
./update-template.sh
```

### Want to experiment with the react app?
To deploy the app, run the deploy-app.sh command.
```
cd ~/environment/docaas-devlab
./deploy-app.sh
```

### How to reset the lab
You can reset the lab at any time by running the following command:
```
cd ~/environment/docaas-devlab
git reset --hard HEAD && git clean --force -d
git checkout master
./reset-lab.sh
```
