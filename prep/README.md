# Prep Steps
## On AWS Organizations
1. Deploy prep-template.yaml into all AWS accounts in the ap-northeast-1 region.

## On Gerardo's account
2. Gerardo to delegate ${AWS::AccountId}.docaas.net to this account's name servers. Then wait 30 min for ACM to be validated.

## On Cloud9
3. Clone the repo, create ACM in us-east-1, validate it, bootstrap template. Then Deploy DoCaas app in the ap-northeast-1 region.
```shell
cd ~/environment
git clone https://github.com/ge8/docaas-devlab && cd docaas-devlab
./prep/acm.sh
./deploy-template.sh 
./deploy-app.sh
```

4. Login and change passwords for 3 users.
