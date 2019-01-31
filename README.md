# Securing Multi-tenant SaaS Applications Built On Serverless Microservices
In this session, we crack open the IDE to secure a multi-tenant SaaS platform built on a ReactJS web app and NodeJS serverless microservices. We use Amazon API Gateway and Amazon Cognito to simplify the operation and security of the service's API and identity functionality. We enforce tenant isolation and data partitioning with OAuth's JWT tokens. We'll then abstract the security complexity from developers to keep operational burden to a minimum, maximizing developer productivity, and maintaining a great developer experience.

# Pre-talk build (single customer functionality – open to the world)
SAM template with:
Cfn + certificate
R53 record
Cognito.
NO PLAN.
APIGW – Cognito auth. (NEW)
7 lambdas – open
No Authorizer.
Deck access helper just writes based on identity-id with Lambda Role.
DynamoDB (multiple customer structure) Deck writing takes identity ID & Lambda Role.
Every user access to them all.

# Demo1: Multi-tenant plans + Access Control
Plan attribute.
Author Lambda Authoriser.
Change APIGW to Lambda Authoriser.
Deck access helper STILL just writes based on identity-id with Lambda Role.
Test access.

# Demo 2: Data Partitioning + Abstracting Dev Complexity.
Notice that Deck access helper STILL just writes based on identity-id with Lambda Role.
Show Data Partitioning issue… Dev mistake. User A modifies User B.
Modify Lambda Authorizer to return or use Context.
New Policy for Cognito.
Modify Deck-Data Helper to use this!
