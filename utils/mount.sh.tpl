#!/bin/bash
set -euxo pipefail

echo "==== [START] Mounting Volumes ===="

MOUNTPOINT="${mountpoint}"
LABEL="${label}"

# Detecta o segundo disco automaticamente (ignora o root nvme0n1)
DEVICE=$(lsblk -dpno NAME,TYPE | awk '$2=="disk"{print $1}' | grep -v nvme0n1 | head -n1)

if [ -z "$DEVICE" ] || [ ! -b "$DEVICE" ]; then
  echo "Nenhum disco detectado; pulando."
  exit 0
fi

echo "Disco de dados detectado: $DEVICE"

# Detecta partição existente
part_name=$(lsblk -nr -o NAME,TYPE "$DEVICE" | awk '$2=="part"{print $1; exit}')

# Cria tabela e partição se não existir
if [ -z "$part_name" ]; then
  parted -s "$DEVICE" mklabel gpt
  parted -s "$DEVICE" mkpart primary ext4 0% 100%
  udevadm settle || true
  sleep 3
  part_name=$(lsblk -nr -o NAME,TYPE "$DEVICE" | awk '$2=="part"{print $1; exit}')
fi

PART="/dev/$part_name"

while [ ! -b "$PART" ]; do sleep 1; done

FSTYPE=$(lsblk -no FSTYPE "$PART")

# Formata apenas se necessário
if [ -z "$FSTYPE" ]; then
  mkfs.ext4 -F -L "$LABEL" "$PART"
fi

UUID=$(blkid -s UUID -o value "$PART" || true)

if [ -z "$UUID" ]; then
  echo "ERRO: UUID não encontrado. Abortando montagem."
  exit 1
fi

mkdir -p "$MOUNTPOINT"

# Adiciona ao fstab apenas se não existir
if ! grep -q "$MOUNTPOINT" /etc/fstab; then
  echo "UUID=$UUID $MOUNTPOINT ext4 defaults,nofail,x-systemd.device-timeout=10s 0 2" >> /etc/fstab
fi

mount -a

echo "Montado: $PART -> $MOUNTPOINT"

echo "==== [END] Mounting Volumes ===="


echo "==== [ Redirect /var/www ] ===="

if [ ! -L /var/www ]; then
  if [ -d /var/www ] && [ ! -d "$${MOUNTPOINT}/www" ]; then
    mv /var/www /var/www.bak || true
  fi

  mkdir -p "$MOUNTPOINT/www"
  rm -rf /var/www
  ln -s "$MOUNTPOINT/www" /var/www
fi

chown -R www-data:www-data "$MOUNTPOINT/www"

echo "==== [END Redirect] ===="

echo "==== Creating User and Setting up SSH ===="

USER="${username}"

# Cria o usuário apenas se nao existir
if ! id "$USER" >/dev/null 2>&1; then
  adduser --disabled-password --gecos "" "$USER" || true
fi

# Permitir sudo sem senha
if [ ! -f /etc/sudoers.d/$USER ]; then
  echo "$USER ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/$USER
  chmod 440 /etc/sudoers.d/$USER
fi

# SSH
mkdir -p /home/$USER/.ssh
chmod 700 /home/$USER/.ssh

# Detecta o usuário padrão automaticamente (Ubuntu, Debian, Amazon Linux etc.)
DEFAULT_USER=$(ls /home | grep -v "$USER" | head -n1)

# Copia chave SSH se existir
for i in {1..30}; do
  if [ -f /home/$DEFAULT_USER/.ssh/authorized_keys ]; then
    cp "/home/$DEFAULT_USER/.ssh/authorized_keys" "/home/$USER/.ssh/authorized_keys"
    chmod 600 "/home/$USER/.ssh/authorized_keys"
    chown -R $USER:$USER /home/$USER/.ssh
    break
  fi
  sleep 2
done

echo "==== User $USER created successfully ===="

# Enable Chrony
systemctl enable --now chrony || true

echo "==== [START] Setting permissions for volume ===="

# Criar grupo webdev (se não existir)
if ! getent group webdev >/dev/null; then
  groupadd webdev
fi

# Adicionar usuário devops ao grupo webdev
usermod -aG webdev "$USER"

# Ajustar dono e permissões do volume
if [ -d "$MOUNTPOINT" ]; then
  chown -R root:webdev "$MOUNTPOINT"
  chmod -R 775 "$MOUNTPOINT"
  chmod g+s "$MOUNTPOINT"
fi

echo "==== [END] Setting permissions ===="
