#!/bin/bash

set -e

: "${VERSION:=6.1.0}"
: "${LUSTRE_VERSION:=2.12.4}"


mkdir -p /tmp/iml-build
cd /tmp/iml-build


if [[ -z "$MANAGER_ONLY" && ! -z "$WITH_LUSTRE_PATCHLESS" ]]; then
  echo "Adding e2fsprogs repo"

  yum-config-manager --add-repo=https://downloads.whamcloud.com/public/e2fsprogs/latest/el7/

  echo "Adding Patchless Lustre repos"

  yum-config-manager --add-repo=https://downloads.whamcloud.com/public/lustre/lustre-${LUSTRE_VERSION}/el7/patchless-ldiskfs-server/
  yum-config-manager --add-repo=http://download.zfsonlinux.org/epel/7.6/kmod/x86_64/

  yumdownloader --resolve -y pcs fence-agents fence-agents-virsh lustre-resource-agents lustre-ldiskfs-zfs-patchles
fi

echo "Adding IML manager repos"

yum-config-manager --add-repo=https://github.com/whamcloud/integrated-manager-for-lustre/releases/download/v$VERSION/chroma_support.repo
yumdownloader --resolve -y python2-iml-manager

if [[ -z "$MANAGER_ONLY" ]]; then
  yumdownloader --resolve -y python2-iml-agent python2-iml-agent-management rust-iml-agent;
fi

createrepo --pretty ./
cd /build
tar -C /tmp -czvf iml-bundle-v${VERSION}.tar.gz iml-build