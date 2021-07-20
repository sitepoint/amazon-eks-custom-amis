#!/usr/bin/env bash

set -o pipefail
set -o nounset
set -o errexit

source /etc/packer/files/functions.sh

ARCH=$(get_arch)

if (is_rhel && is_rhel_7) || (is_centos && is_centos_7); then

  yum remove -y \
    docker \
    docker-client \
    docker-client-latest \
    docker-common \
    docker-latest \
    docker-latest-logrotate \
    docker-logrotate \
    docker-selinux \
    docker-engine-selinux \
    docker-engine

  yum install -y device-mapper-persistent-data lvm2 yum-utils
  yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
  sed -i 's/\$releasever/7/g' /etc/yum.repos.d/docker-ce.repo
  yum install -y docker-ce docker-ce-cli containerd.io

elif (is_rhel && is_rhel_8) || (is_centos && is_centos_8); then

  dnf remove -y \
    docker \
    docker-client \
    docker-client-latest \
    docker-common \
    docker-latest \
    docker-latest-logrotate \
    docker-logrotate \
    docker-selinux \
    docker-engine-selinux \
    docker-engine

  dnf install -y device-mapper-persistent-data lvm2
  dnf config-manager --add-repo=https://download.docker.com/linux/centos/docker-ce.repo
  dnf install -y docker-ce docker-ce-cli containerd.io

elif is_ubuntu; then

  apt-get install -y apt-transport-https ca-certificates curl gnupg-agent software-properties-common
  #curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
  #add-apt-repository "deb [arch=${ARCH}] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
  #apt-get update -y
  #apt-get install -y docker-ce docker-ce-cli containerd.io

  add-apt-repository -y ppa:tuxinvader/lts-mainline
  apt-get update
  apt-get install -y linux-generic-5.12

  # Install required packages
  apt-get install -y \
    iptables libseccomp2 socat conntrack ipset \
    fuse3 \
    jq \
    iproute2 \
    auditd \
    ethtool \
    net-tools

  mkdir -p /etc/modules-load.d/

  # Enable modules
  cat <<EOF > /etc/modules-load.d/k8s.conf
ena
overlay
fuse
br_netfilter
EOF

  # Disable modules
  cat <<EOF > /etc/modprobe.d/kubernetes-blacklist.conf
blacklist dccp
blacklist sctp
EOF

  # Configure grub
  #echo "GRUB_GFXPAYLOAD_LINUX=keep" >> /etc/default/grub
  # Enable cgroups2
  #sed -i 's/GRUB_CMDLINE_LINUX="\(.*\)"/GRUB_CMDLINE_LINUX="systemd.unified_cgroup_hierarchy=1 cgroup_no_v1=all \1"/g' /etc/default/grub
  #update-grub2

  # Install containerd
  curl -sSL https://github.com/containerd/nerdctl/releases/download/v0.10.0/nerdctl-full-0.10.0-linux-amd64.tar.gz -o - | tar -xz -C /usr/local

  mkdir -p /etc/containerd /etc/containerd/certs.d

  cp /etc/packer/files/gitpod/containerd.toml /etc/containerd/config.toml

  cp /usr/local/lib/systemd/system/* /lib/systemd/system/
  sed -i 's/--log-level=debug//g' /lib/systemd/system/stargz-snapshotter.service

  cp /usr/local/lib/systemd/system/* /lib/systemd/system/
  # Disable software irqbalance service
  systemctl stop irqbalance.service
  systemctl disable irqbalance.service

  # Reload systemd
  systemctl daemon-reload

  mkdir -p /etc/containerd-stargz-grpc/

  # Install kata containers
  #snap install kata-containers --stable --classic
  #mkdir -p /etc/kata-containers
  #cp /snap/kata-containers/current/usr/share/defaults/kata-containers/configuration.toml /etc/kata-containers/
  #ln -sf /snap/kata-containers/current/usr/bin/containerd-shim-kata-v2 /usr/local/bin/containerd-shim-kata-v2

  # Start containerd and stargz
  systemctl enable containerd
  systemctl enable stargz-snapshotter

  systemctl start containerd

  chmod +x /etc/packer/files/gitpod/pre-pull.sh
  /etc/packer/files/gitpod/pre-pull.sh

  sleep 60
  systemctl stop containerd

else

  echo "could not install docker, operating system not found!"
  exit 1

fi
