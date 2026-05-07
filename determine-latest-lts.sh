#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

# Fail fast if `jq` is missing
command -v jq 2>/dev/null || { echo "$(basename "$0"): 'jq' command not found."; exit 1; }

curl --silent --fail 'https://repo.jenkins-ci.org/api/search/versions?g=org.jenkins-ci.main&a=jenkins-core&repos=releases&v=?.*.*' | jq --raw-output '.results[].version' | head -n 1
