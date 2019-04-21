# Prep Steps
1. Create Resources in Lab Account: R53, S3, C9
```shell
cd ~/Desktop
./prep/prep.sh
```

2. Gerardo to delegate ${AWS::AccountId}.docaas.net to this account's name servers. Then wait 30 min for ACM to be validated.

3. Create ACM Resource in Lab Account and Validate it.
```shell
cd ~/Desktop
./prep/acm.sh
```