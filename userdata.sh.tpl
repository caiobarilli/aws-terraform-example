#!/bin/bash
set -euxo pipefail

exec > >(tee -a /var/log/user-data.log) 2>&1

export DEBIAN_FRONTEND=noninteractive

echo "==== [START] User Data Script ===="

echo "==== [START] Installing Packages ===="

apt-get update -y
apt-get install -y \
  wget \
  ca-certificates \
  curl \
  gnupg \
  lsb-release \
  lvm2 \
  python-is-python3 \
  python3-apt \
  python3-pip \
  s3cmd \
  parted \
  zip \
  unzip \
  tar \
  curl \
  cron \
  jq \
  chrony

echo "==== [END] Installing Packages ===="

# Mount Script
${mount_script}

# Cleanup Script
${cleanup_script}

echo "==== [END] User Data Script ===="
