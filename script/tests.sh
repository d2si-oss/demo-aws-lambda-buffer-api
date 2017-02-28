#!/usr/bin/env bash

set -e
set -x

echo 'run tests'
# unit tests
cd code/buffer/tests
python tests_*
