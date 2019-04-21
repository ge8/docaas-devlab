#!/bin/bash

ACCOUNT=$(aws sts get-caller-identity --output text --query 'Account')
TAIL="docaas-devlab"

export SAMBUCKET="$ACCOUNT-$TAIL"
export REGION=ap-southeast-2
export STACK=docaas-summit
