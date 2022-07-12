#!/bin/bash

set -e

pip install pip-upgrader
pip-upgrade --skip-package-installation -p octoprint

if [ -z "git diff" ]; then
    echo "No updates were found"
    exit 0
fi

echo "Updates detected"
env
git config user.email updater@devnull.localhost
git config user.name Updater

git checkout -b dependency-update/octoprint-x

git commit -a -m "Auto-updated dependencies"

git push origin dependency-update/octoprint-x

echo "https://api.github.com/repos/$repo/pulls"

# create the PR
# if PR already exists, then update
response=$(curl --write-out "%{message}\n" -X POST -H "Content-Type: application/json" -H "Authorization: token $1" \
        --data '{"title":"Autoupdate dependencies","head": "'"$branch_name"'","base":"main", "body":"Auto-generated pull request. \nThis pull request is generated by GitHub action based on the provided update commands."}' \
        "https://api.github.com/repos/$repo/pulls")

echo $response   

if [[ "$response" == *"already exist"* ]]; then
    echo "Pull request already opened. Updates were pushed to the existing PR instead"
    exit 0
fi
