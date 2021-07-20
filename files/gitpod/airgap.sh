#!/usr/bin/env bash

set -o pipefail
set -o nounset
set -o errexit

DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)

IMAGES=$(cat "${DIR}/airgap-images.txt")

# Download images
xargs -n1 nerdctl --namespace k8s.io pull <<< "${IMAGES}"

# Export images to tar file
nerdctl --namespace k8s.io save -o /airgap-images.tar $(echo "${IMAGES[*]}")

# Compress tar file
gzip -v -c /airgap-images.tar > /airgap-images.tar.gz

# Cleanup
rm /airgap-images.tar
