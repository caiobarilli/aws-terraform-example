#!/bin/bash
set -euxo pipefail
exec > >(tee -a /var/log/user-data.log) 2>&1
export DEBIAN_FRONTEND=noninteractive

echo "==== [START] User Data Script ===="

########################################################
#  PACOTES INSTALADOS PELO SISTEMA
#
#  ca-certificates
#     - Mantém certificados SSL atualizados para conexões HTTPS
#
#  curl
#     - Ferramenta de linha de comando para realizar requisições HTTP/HTTPS
#
#  gnupg
#     - Suporte a criptografia GPG (assinatura e verificação de pacotes/repos)
#
#  lsb-release
#     - Fornece identificação da distribuição (versão, codename)
#
#  lvm2
#     - Ferramentas para gerenciamento de volumes LVM
#       (útil em sistemas com discos dinâmicos)
#
#  python-is-python3
#     - Permite que "python" aponte para o binário python3
#
#  python3-apt
#     - Biblioteca Python para manipular repositórios e pacotes APT
#
#  python3-pip
#     - Gerenciador de pacotes Python para instalar utilitários adicionais
#
#  s3cmd
#     - CLI para acessar buckets S3 (upload/download/ls/sync)
#
#  parted
#     - Ferramenta essencial para criação e ajuste de partições
#       (necessário para discos NVMe/EBS recém conectados)
#
#  jq
#     - Manipulação de JSON via linha de comando
#       (extremamente útil para scripts)
#
#  chrony
#     - Sincronização de tempo moderna e mais eficiente que o NTP tradicional
########################################################

echo "==== [START] Installing Packages ===="

apt-get update -y
apt-get install -y \
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
  jq \
  chrony

########################################################
#  BLOCO DE MONTAGEM IMPORTADO DO utils/mount.sh.tpl
########################################################
${mount_script}

########################################################
#  BLOCO DE LIMPEZA IMPORTADO DE utils/cleanup.sh.tpl
########################################################
${cleanup_script}
