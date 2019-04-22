# Prep Steps
## On AWS Organizations
1. Deploy c9.yaml into all AWS accounts in the ap-northeast-1 region.

## On Cloud9
2. Clone the repo and create Resources in Lab Account: R53, S3 in ap-northeast-1
```shell
cd ~/environment
git clone https://github.com/ge8/docaas-devlab
cd ~/environment/docaas-devlab
./prep/prep.sh
```

## On Gerardo's account
3. Gerardo to delegate ${AWS::AccountId}.docaas.net to this account's name servers. Then wait 30 min for ACM to be validated.

## On Cloud9
4. Create ACM in us-east-1 and validate it. Then Deploy DoCaas app:
```shell
cd ~/environment/docaas-devlab
./prep/acm.sh
./deploy-template.sh 
./deploy-app.sh
```