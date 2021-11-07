#!/bin/bash
# usage: ./deploy.sh <VERSION> <DATABRICKS_TOKEN> <REPO_PATH> 

# !! todo: fix the databricks config --token or use file
# todo: allow user to pass in specific repository to deploy to databricks
# todo: parameterize defaults
# todo: parameterize a test|deploy function

# setup - ensure databricks cli is installed
pip3 install databricks-cli;

REPO_PATH="${3:-/opt}"
REPO_HOME="${REPO_PATH}/project-databricks"


if [[ -d ${REPO_HOME} ]]; then
    echo "Removing existing repo to keep things clean..."
    rm -rf ${REPO_HOME}
fi

# clone repository to REPO_PATH, if not set, then default to tmp
echo "Cloning repository... (THIS ASSUMES YOU HAVE AN SSH KEY REGISTERED IN GITHUB)"
git clone git@github.com:Organization/somerepo.git "${REPO_HOME}" && cd "$_" ;

HEAD=$(cat ${REPO_HOME}/.git/HEAD)
BRANCH=${HEAD##*refs/heads/}

echo "Checking out specific branch by tag ${1} ..."
git checkout "tags/v${1}";
#git pull;

echo "Creating databricks config file..."
cat <<EOF | tee ~/.databrickscfg
[DEFAULT]                                                                                                                                                          
host = https://cmw-prod.cloud.databricks.com
token = ${2}

EOF

echo importing ${BRANCH}...
echo "${1}"
databricks workspace import_dir -e -o ${REPO_HOME} /prod/Ver-${1}/
