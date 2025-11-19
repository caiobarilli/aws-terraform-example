# AWS EC2 com Terraform

Este repositório provisiona uma infraestrutura completa na AWS usando Terraform, incluindo:

- Instância EC2 baseada em Ubuntu 24.04 LTS
- Volume EBS adicional com automontagem
- Script user_data para particionar, formatar, montar e redirecionar `/var/www`
- Segurança via Security Group
- Backend remoto opcional (S3 + DynamoDB)
- AMI localizada automaticamente via filtros

# FLUXO DE BACKEND REMOTO

Após rodar o terraform init, o estado inicial será salvo localmente.

Para habilitar o backend remoto, siga o fluxo correto:

Primeiro, execute o Terraform com os recursos do backend descomentados para criar o bucket S3 e a tabela DynamoDB:

```
terraform apply
```

Em seguida, descomente a configuração do backend S3 no bloco terraform { backend "s3" {...} }.

Rode o comando:

```
terraform init -reconfigure
```

Confirme a migração do estado para o S3 quando solicitado.

A partir desse ponto, o Terraform passa a usar o estado remoto armazenado no bucket S3, garantindo consistência e segurança em todas as execuções futuras.

O backend remoto permite controle de concorrência, versionamento opcional do estado e facilita o uso do mesmo ambiente por múltiplos operadores ou máquinas.

# Pré-requisitos

- Conta AWS ativa
- AWS CLI configurado
  ```
  aws configure
  ```
- Terraform 1.5+
- Chave pública SSH (id_ed25519.pub ou id_rsa.pub)

# WordPress One-Click (WordOps)

Acesse a instância via SSH:

```
ssh devops@seu-endereco-ip
```

Instale o WordOps:

```
wget -qO wo wops.cc && sudo bash wo
```

Crie seu site WordPress com cache, PHP 8.4, Let's Encrypt, HSTS e senha administrativa:

```
sudo wo site create meusite.com.br --wpfc --php84 --letsencrypt --hsts --pass='example' --email='jonh.doe@email.com'
```

# Comandos úteis

```
terraform init

terraform init -reconfigure

terraform plan

terraform apply

terraform apply -replace="aws_instance.example-server"

terraform output

terraform destroy

terraform console

```
