#!/bin/bash
# usage: ./deploy.sh <VERSION> <DATABRICKS_TOKEN> <REPO_PATH> 

REPO_PATH="${3:-/opt}"
REPO_HOME="${REPO_PATH}/DE_cdl-databricks"


if [[ -d ${REPO_HOME} ]]; then
    echo "Removing existing repo to keep things clean..."
    rm -rf ${REPO_PATH}
fi

# clone repository to REPO_PATH, if not set, then default to tmp
echo "Cloning repository... (THIS ASSUMES YOU HAVE AN SSH KEY REGISTERED IN GITHUB)"
git clone git@github.com:CadentTech/DE_cdl-databricks.git "${REPO_HOME}" && cd "$_" ;

HEAD=$(cat ${REPO_HOME}/.git/HEAD)
BRANCH=${HEAD##*refs/heads/}

echo "Checking out specific branch by tag ${1} ..."
git checkout "tags/v${1}";
#git pull;

echo "Creating databricks config file..."
cat <<EOF | tee ~/.databrickscfg
[DEFAULT]                                                                                                                                                          
host = https://cmw-prod.cloud.databricks.com
token = "${2}"
EOF

echo importing ${BRANCH}...
echo "${1}"
databricks workspace import_dir -e -o ${REPO_HOME} /prod/Ver-${1}/
