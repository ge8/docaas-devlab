# Prep Steps
1. Clone the repo
```shell
cd ~/environment
git clone https://github.com/ge8/docaas-devlab
```

2. Create Resources in Lab Account: R53, S3 in region of choice
```shell
cd ~/environment/docaas-devlab
./prep/prep.sh
```

3. Gerardo to delegate ${AWS::AccountId}.docaas.net to this account's name servers. Then wait 30 min for ACM to be validated.

4. Create ACM and C9 in us-east-1 Resource in Lab Account and Validate it.
```shell
cd ~/environment/docaas-devlab
./prep/acm+c9.sh
```

5. Deploy DoCaas app
```shell
cd ~/environment/docaas-devlab
./deploy-template.sh 
./deploy-app.sh
```