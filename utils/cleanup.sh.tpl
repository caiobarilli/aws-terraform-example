#!/bin/bash
set -euxo pipefail

# ---------------------------------------
# Limpeza para reduzir uso de disco
# ---------------------------------------

echo "==== [START] Cleanup ===="

# Remove cache do APT
apt-get clean

# Remove listas de pacotes
rm -rf /var/lib/apt/lists/*

# Limita logs do systemd journals
journalctl --vacuum-size=50M || true
