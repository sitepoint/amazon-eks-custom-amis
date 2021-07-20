#!/usr/bin/env bash

set -o pipefail
set -o nounset
set -o errexit

declare -a IMAGES=(
    eu.gcr.io/gitpod-core-dev/build/blobserve:aledbf-retag.27
    eu.gcr.io/gitpod-core-dev/build/content-service:aledbf-retag.27
    eu.gcr.io/gitpod-core-dev/build/dashboard:aledbf-retag.27
    eu.gcr.io/gitpod-core-dev/build/image-builder:aledbf-retag.27
    eu.gcr.io/gitpod-core-dev/build/proxy:aledbf-retag.27
    eu.gcr.io/gitpod-core-dev/build/registry-facade:aledbf-retag.27
    eu.gcr.io/gitpod-core-dev/build/seccomp-profile-installer:aledbf-retag.27
    eu.gcr.io/gitpod-core-dev/build/server:aledbf-retag.27
    eu.gcr.io/gitpod-core-dev/build/service-waiter:aledbf-retag.27
    eu.gcr.io/gitpod-core-dev/build/ws-daemon:aledbf-retag.27
    eu.gcr.io/gitpod-core-dev/build/ws-manager:aledbf-retag.27
    eu.gcr.io/gitpod-core-dev/build/ws-manager-bridge:aledbf-retag.27
    eu.gcr.io/gitpod-core-dev/build/ws-proxy:aledbf-retag.27
    docker.io/bitnami/rabbitmq:3.8.17-debian-10-r1
    docker.io/jaegertracing/all-in-one:1.22.0
    docker.io/library/alpine:3.14
    docker.io/library/docker:20.10.7-dind-rootless
    docker.io/library/registry:2.7.1
    docker.io/library/ubuntu:20.04
    docker.io/amazon/aws-for-fluent-bit:2.13.0
    docker.io/bitnami/external-dns:0.8.0-debian-10-r26
    docker.io/bitnami/metrics-server:0.5.0-debian-10-r32
    docker.io/calico/cni:v3.19.1
    docker.io/calico/node:v3.19.1
    docker.io/calico/pod2daemon-flexvol:v3.19.1
    k8s.gcr.io/autoscaling/cluster-autoscaler:v1.20.0
    k8s.gcr.io/pause:3.5
    quay.io/brancz/kube-rbac-proxy:v0.9.0
    quay.io/jetstack/cert-manager-cainjector:v1.4.0
    quay.io/jetstack/cert-manager-controller:v1.4.0
    quay.io/jetstack/cert-manager-webhook:v1.4.0
)

for IMAGE in "${IMAGES[@]}"; do
    ctr --namespace k8s.io images pull "$IMAGE"
done
