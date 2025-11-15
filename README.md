# AWS EC2 com Terraform

Este repositório provisiona uma infraestrutura completa na AWS usando Terraform, incluindo:

- Instância EC2 baseada em Ubuntu 24.04 LTS
- Volume EBS adicional com automontagem
- Script user_data para particionar, formatar, montar e redirecionar `/var/www`
- Segurança via Security Group
- Backend remoto opcional (S3 + DynamoDB)
- AMI localizada automaticamente via filtros

# Pré-requisitos

- Conta AWS ativa
- AWS CLI configurado
  ```
  aws configure
  ```
- Terraform 1.5+
- Chave pública SSH (id_ed25519.pub ou id_rsa.pub)

# Criando o arquivo terraform.tfvars

Crie o arquivo:

```
cp terraform.tfvars.example terraform.tfvars
nano terraform.tfvars
```

Use um conteúdo completo como este:

```
# Região AWS
aws_region        = "us-east-1"

# AMI
ami_name_pattern  = "ubuntu/images/hvm-ssd*/ubuntu-noble-24.04-amd64-server-*"
ami_owners        = ["099720109477"] # Canonical

# Instância
instance_name     = "example-server"
instance_type     = "t3.micro"

# SSH e Key Pair
key_name          = "dev_key"          # Nome da Key Pair na AWS
key_path          = "id_ed25519.pub"   # Caminho da chave pública local
ssh_cidr          = "192.157.61.69/32" # Seu IP para acesso SSH

# VPC e Subnet
vpc_id            = "vpc-0f5cbc8c491c269ee"
vpc_subnet_id     = "subnet-0f898f79dabfbb7d5"

# Volume EBS adicional
ec2_mountpoint    = "/example_mountpoint"
ec2_volume_label  = "example_volume"

```

# Fluxo recomendado de uso (PASSO A PASSO)

Este projeto usa backend remoto (S3+DynamoDB), mas o fluxo correto é fazer um _bootstrap_ antes.

## 1. BOOTSTRAP (rodar sem backend)

Certifique-se de que o `backend.tf` está comentado:

```
# terraform {
#   backend "s3" {
#     bucket  = "terraform-state-example-4532423423422"
#     key     = "terraform.tfstate"
#     region  = "us-east-1"
#     encrypt = true
#   }
# }

```

Execute:

```
terraform init

terraform plan

terraform apply
```

Isso cria:

- A instância EC2
- Volume EBS
- Security Group
- Script user_data montando o volume

Ainda **sem backend remoto ativado**.

---

# 2. CRIAR os recursos do backend remoto (S3 + DynamoDB)

Descomente o arquivo `backend-resource.tf`:

```
resource "aws_s3_bucket" "terraform_state" {
  bucket = "terraform-state-example-4532423423422"
  lifecycle { prevent_destroy = true }
}

resource "aws_dynamodb_table" "terraform_locks" {
  name         = "terraform-locks-example-4532423423422"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"
  attribute { name = "LockID" type = "S" }
  lifecycle { prevent_destroy = true }
}
```

Aplique:

```
terraform apply
```

Agora o bucket e a tabela existem.

---

# 3. ATIVAR backend remoto S3 + DynamoDB

Descomente o arquivo `backend.tf`:

```
terraform {
  backend "s3" {
    bucket         = "terraform-state-example-4532423423422"
    key            = "terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks-example-4532423423422"
    encrypt        = true
  }
}
```

Execute:

```
terraform init
```

Terraform vai perguntar:

```
Do you want to copy the existing state to the new backend? (yes/no)
```

Responda:

```
yes
```

Agora o estado está no S3 e com locking no DynamoDB.

---

# Comandos úteis

```
terraform init

terraform plan

terraform apply

terraform apply -replace="aws_instance.example-server"

terraform output

terraform destroy
```
