#!/bin/bash
set -euxo pipefail

# ---------------------------------------
# Limpeza para reduzir uso de disco
# ---------------------------------------

echo "==== [START] Cleanup ===="

# Remove cache do APT
apt-get clean

echo "==== [END] Cleanup ===="
