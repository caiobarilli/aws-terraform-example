#!/bin/bash
set -euxo pipefail

# ---------------------------------------
# Montagem de volumes EBS/NVMe
# ---------------------------------------
echo "==== [START] Mounting Volumes ===="

# Diretório de montagem vindo do Terraform
MOUNTPOINT="${mountpoint}"

# Label do volume vindo do Terraform
LABEL="${label}"

# Lista de dispositivos possíveis: NVMe (Nitro) e clássicos /dev/sdX
CANDIDATES="/dev/nvme1n1 /dev/nvme2n1 /dev/xvdf /dev/xvdd /dev/sdf /dev/sdd"
DEVICE=""

# Aguarda até 120s (24 tentativas x 5s) por qualquer disco aparecer
for i in $(seq 1 24); do
  for d in $CANDIDATES; do
    # Encontrou um bloco de disco
    if [ -b "$d" ]; then DEVICE="$d"; break 2; fi
  done
  sleep 5
done

if [ -n "$DEVICE" ]; then
  echo "Disco de dados detectado: $DEVICE"

  # Garante que existe a partição 1
  if ! lsblk -no NAME "$DEVICE" | grep -qE "$(basename "$DEVICE")p?1"; then
    # Cria tabela GPT
    parted -s "$DEVICE" mklabel gpt

    # Cria partição 100%
    parted -s "$DEVICE" mkpart primary ext4 0% 100%

    udevadm settle || true
    sleep 3
  fi

  # Define corretamente a partição (NVMe usa "p1")
  if echo "$DEVICE" | grep -q nvme; then
    PART="$${DEVICE}p1"
  else
    PART="$${DEVICE}1"
  fi

  # Formata a partição se ainda não houver filesystem
  if [ -z "$(lsblk -no FSTYPE "$PART")" ]; then
    mkfs.ext4 -F -L "$LABEL" "$PART"
  fi

  # Adiciona ao /etc/fstab usando LABEL (mais robusto que /dev/...)
  mkdir -p "$MOUNTPOINT"
  if ! grep -q "LABEL=$LABEL" /etc/fstab; then
    echo "LABEL=$LABEL $MOUNTPOINT ext4 defaults,nofail 0 0" >> /etc/fstab
  fi

  # Monta tudo do fstab
  mount -a
  echo "Montado: $PART -> $MOUNTPOINT"
else
  echo "Nenhum disco de dados detectado; pulando montagem."
fi

# ============================================================
#  REDIRECIONAR /var/www PARA O VOLUME EXTRA
# ============================================================

echo "==== [START] Redirect /var/www to mounted volume ===="

# Parar serviços web (se existirem)
systemctl stop nginx || true
systemctl stop php8.4-fpm || true
systemctl stop php8.2-fpm || true  # fallback

# Backup se /var/www existir
if [ -d /var/www ]; then
  echo "Movendo /var/www para backup..."
  mv /var/www /var/www.bak || true
fi

# Criar nova pasta /var/www dentro do volume
mkdir -p "$MOUNTPOINT/www"

# Criar symlink
ln -s "$MOUNTPOINT/www" /var/www

# Ajustar permissões
chown -R www-data:www-data "$MOUNTPOINT/www"

echo "Symlink criado: /var/www -> $MOUNTPOINT/www"
