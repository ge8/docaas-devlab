# Securing SaaS Applications Built On Serverless Microservices
![N|Solid](https://upload.wikimedia.org/wikipedia/commons/9/93/Amazon_Web_Services_Logo.svg =100x)
In this DevLab, you'll crack open the IDE to secure a SaaS platform built on a ReactJS web app and NodeJS serverless microservices. The app uses Amazon API Gateway and Amazon Cognito to simplify the operation and security of the service's API and identity functionality. You'll enforce user isolation and data partitioning with OAuth's JWT tokens. You'll also abstract the security complexity from developers to keep operational burden to a minimum, maximizing developer productivity, and maintaining a great developer experience.

# Lab 0: Check the app out
* Play with the app (labx.docaas.net) by:
** Using an incognito Chrome browser, and login with username: bronze1 password: Permanent1!
** Using an incognito Firefox browser, and login with username: silver1 password: Permanent1!
** Using an incognito Edge browser, and login with username: silver1 password: Permanent1!

* Check out the reactjs app
Open VS Code + 

* Check out SAM template

* Check out CloudFormation resources using the AWS Console.

# Lab 1: Browser Protection + Access Control based on SaaS plan attribute


# Lab 2: Data Partitioning and Abstracting Security Complexity from Devs


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
