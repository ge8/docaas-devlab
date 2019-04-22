#!/bin/bash

export ACCOUNT=$(aws sts get-caller-identity --output text --query 'Account')
TAIL1="docaas-devlab"
TAIL2="docaas.net"

export SAMBUCKET="$ACCOUNT-$TAIL1"
export DOMAIN="$ACCOUNT.$TAIL2"
export REGION=ap-northeast-1
export STACK=docaas-devlab
