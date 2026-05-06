#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

curl --silent --fail 'https://repo.jenkins-ci.org/api/search/versions?g=org.jenkins-ci.main&a=jenkins-core&repos=releases&v=?.*.*' | jq --raw-output '.results[].version' | head -n 1
