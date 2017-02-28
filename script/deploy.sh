#!/usr/bin/env bash

set -e
set -x

deploy()
{
  env=$1
  cd code/buffer
  apex deploy --env $env
}

# Start the deploy here
if [[ $TRAVIS_BRANCH == "staging" ]]; then
  deploy 'staging'
fi

if [[ $TRAVIS_BRANCH == "master" ]]; then
  deploy 'dev'
fi
