#!/bin/bash
set -euxo pipefail

echo "==== [START] Mounting Volumes ===="

MOUNTPOINT="${mountpoint}"
LABEL="${label}"

CANDIDATES="/dev/nvme1n1 /dev/nvme2n1 /dev/xvdf /dev/xvdd /dev/sdf /dev/sdd"
DEVICE=""

for i in $(seq 1 24); do
  for d in $CANDIDATES; do
    if [ -b "$d" ]; then
      DEVICE="$d"
      break 2
    fi
  done
  sleep 5
done

if [ -n "$DEVICE" ]; then
  echo "Disco de dados detectado: $DEVICE"

  # Verifica partição existente — corrigido para escapar HCL
  if lsblk -n -o NAME "$DEVICE" | grep -Eq "^$${DEVICE##*/}p?1$"; then
    echo "Partição já existente; não será recriada."
  else
    echo "Nenhuma partição encontrada; criando..."
    parted -s "$DEVICE" mklabel gpt
    parted -s "$DEVICE" mkpart primary ext4 0% 100%
    udevadm settle || true
    sleep 3
  fi

  # Partição correta — já está escapado corretamente
  if echo "$DEVICE" | grep -q nvme; then
    PART="$${DEVICE}p1"
  else
    PART="$${DEVICE}1"
  fi

  if [ -z "$(lsblk -no FSTYPE "$PART")" ]; then
    mkfs.ext4 -F -L "$LABEL" "$PART"
  fi

  mkdir -p "$MOUNTPOINT"

  if ! grep -q "LABEL=$LABEL" /etc/fstab; then
    echo "LABEL=$LABEL $MOUNTPOINT ext4 defaults,nofail,x-systemd.device-timeout=10s 0 2" >> /etc/fstab
  fi

  mount -a
  echo "Montado: $PART -> $MOUNTPOINT"

else
  echo "Nenhum disco detectado; pulando."
fi

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
  adduser --disabled-password --gecos "" $USER
fi

# Permitir sudo sem senha
if [ ! -f /etc/sudoers.d/$USER ]; then
  echo "$USER ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/$USER
  chmod 440 /etc/sudoers.d/$USER
fi

# SSH
mkdir -p /home/$USER/.ssh
chmod 700 /home/$USER/.ssh

if [ -f /home/ubuntu/.ssh/authorized_keys ]; then
  cp /home/ubuntu/.ssh/authorized_keys /home/$USER/.ssh/authorized_keys
  chmod 600 /home/$USER/.ssh/authorized_keys
  chown -R $USER:$USER /home/$USER/.ssh
else
  echo "WARNING: /home/ubuntu/.ssh/authorized_keys não existe!"
fi

echo "==== User $USER created successfully ===="

# Enable Chrony
systemctl enable --now chrony

echo "==== [START] Setting permissions for volume ===="

# Criar grupo webdev (se não existir)
if ! getent group webdev >/dev/null; then
  groupadd webdev
fi

# Adicionar usuário ao grupo webdev
usermod -aG webdev "$USER"

# Ajustar dono e permissões do volume para permitir escrita pelo grupo
if [ -d "$MOUNTPOINT" ]; then
  chown -R root:webdev "$MOUNTPOINT"
  chmod -R 775 "$MOUNTPOINT"
  chmod g+s "$MOUNTPOINT"
fi

echo "==== [END] Setting permissions ===="
