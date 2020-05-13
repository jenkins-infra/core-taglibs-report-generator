#!/bin/bash
set -o errexit
set -o nounset
set -o pipefail

wget -q -O jq https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux64 || { echo "Failed to download jq" >&2 ; exit 1; }
chmod +x jq || { echo "Failed to make jq executable" >&2 ; exit 1; }

export PATH=.:$PATH

function test_which() {
  command -v "$1" >/dev/null || { echo "Not on PATH: $1" >&2 ; exit 1 ; }
}

test_which curl
test_which head
test_which jq

curl --silent --fail 'https://repo.jenkins-ci.org/api/search/versions?g=org.jenkins-ci.main&a=jenkins-core&repos=releases&v=?.*.1' | jq --raw-output '.results[].version' | head -n 1 | cut -d. -f1-2
