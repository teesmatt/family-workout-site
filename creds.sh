#!/bin/bash
#
# Get session token from AWS STS
#
#
# Based on https://gist.github.com/ogavrisevs/2debdcb96d3002a9cbf2

AWS_CLI=`which aws`
AWS_CLI_PROFILE="default"
MFA_PROFILE=mfa
MFA_TOKEN_DURATION=129600

if [ $? -ne 0 ]; then
  echo "AWS CLI is not installed; exiting"
  exit 1
else
  echo "Using AWS CLI: $AWS_CLI"
fi

if [ $# -lt 1 ] ; then
  echo "Usage: $0  <MFA_TOKEN_CODE>"
  echo "Where:"
  echo "   <MFA_TOKEN_CODE> = Code from virtual MFA device"
  exit 2
fi

MFA_TOKEN_CODE=$1

if [ -z $MFA_ARN ]; then
    echo
    echo "You need to set MFA_ARN environment variable."
    echo "Example: export MFA_ARN=arn:aws:iam::808962273082:mfa/joe.dirt";
    echo
else
    echo "MFA_ARN from env: $MFA_ARN";
fi

if [[ -n $AWS_PROFILE ]]; then
    AWS_CLI_PROFILE=$AWS_PROFILE
fi

echo "AWS-CLI Profile: $AWS_CLI_PROFILE"
echo "MFA Token Code: $MFA_TOKEN_CODE"

read AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN <<< \
$( aws --profile $AWS_CLI_PROFILE sts get-session-token \
  --duration $MFA_TOKEN_DURATION  \
  --serial-number $MFA_ARN \
  --token-code $MFA_TOKEN_CODE \
  --output text  | awk '{ print $2, $4, $5 }')
echo "AWS_ACCESS_KEY_ID: " $AWS_ACCESS_KEY_ID
echo "AWS_SECRET_ACCESS_KEY: " $AWS_SECRET_ACCESS_KEY
echo "AWS_SESSION_TOKEN: " $AWS_SESSION_TOKEN

if [ -z "$AWS_ACCESS_KEY_ID" ]
then
  exit 1
fi

aws --profile $MFA_PROFILE configure set aws_access_key_id "$AWS_ACCESS_KEY_ID"
aws --profile $MFA_PROFILE configure set aws_secret_access_key "$AWS_SECRET_ACCESS_KEY"
aws --profile $MFA_PROFILE configure set aws_session_token "$AWS_SESSION_TOKEN"


