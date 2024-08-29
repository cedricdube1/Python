#!/bin/bash
#V1
dotnet-gitversion /updateassemblyinfo

if [[ ${CI_COMMIT_BRANCH} == *master* ]]; then
  BRANCH_TYPE=master
  EXECUTE_TESTS=true
  ENV_NAME=blue
  IMAGE_TAG=$(dotnet-gitversion /showvariable MajorMinorPatch)
elif [ ! -z "${CI_COMMIT_TAG}" ]; then
  BRANCH_TYPE=release
  EXECUTE_TESTS=false
  ENV_NAME=green
  IMAGE_TAG=$(dotnet-gitversion /showvariable MajorMinorPatch)-blue
else
  BRANCH_TYPE=feature
  EXECUTE_TESTS=true
  ENV_NAME=orange
  IMAGE_TAG=$(dotnet-gitversion /showvariable MajorMinorPatch)-${CI_COMMIT_SHORT_SHA}
fi

set -e -x

echo "Branch type: ${BRANCH_TYPE}"
echo "Execute tests: ${EXECUTE_TESTS}"
echo "Env name: ${ENV_NAME}"
echo "Image Tag: ${IMAGE_TAG}"

echo export IMAGE_TAG="${IMAGE_TAG}" >> $CI_PROJECT_DIR/variables
echo export BRANCH_TYPE="${BRANCH_TYPE}" >> $CI_PROJECT_DIR/variables
echo export EXECUTE_TESTS="${EXECUTE_TESTS}" >> $CI_PROJECT_DIR/variables
echo export ENV_NAME="${ENV_NAME}" >> $CI_PROJECT_DIR/variables

echo $(cat $CI_PROJECT_DIR/variables)
