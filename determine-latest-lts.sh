#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

set -x

function die() {
	echo "$(basename "$0"): $*" >&2
	exit 1
}

curl --silent --fail --output jq https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64 || die 'failed to download jq'
chmod +x jq || die 'failed to make jq executable'
results="$(curl --silent --fail 'https://repo.jenkins-ci.org/api/search/versions?g=org.jenkins-ci.main&a=jenkins-core&repos=releases&v=?.*.*')"
versions="$(echo "${results}" | ./jq --raw-output '.results[].version')"
echo "${versions}" | head -n 1

exit 0
