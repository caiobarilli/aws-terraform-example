variable "ami_name_pattern" {
  description = "Padrão da AMI"
  type        = string
  default     = "ubuntu/images/hvm-ssd*/ubuntu-noble-24.04-amd64-server-*"
}

variable "ami_owners" {
  description = "Owner da AMI"
  type        = list(string)
  default     = ["099720109477"] # Canonical
}

variable "aws_region" {
  description = "Region AWS"
  type        = string
  default     = "us-east-1"
}

variable "default_tags" {
  description = "Tags aplicadas em todos os recursos"
  type        = map(string)
  default = {
    Name      = "example"
    customer  = "example"
    protocolo = "server"
  }
}
variable "availability_zone" {
  description = "Zona de disponibilidade da instância"
  type        = string
  default     = "us-east-1a"
}

variable "device_name" {
  description = "Nome do dispositivo para anexar o volume EBS"
  type        = string
  default     = "/dev/sdd"
}

variable "ec2_mountpoint" {
  description = "Ponto de montagem do disco adicional"
  type        = string
  default     = "/mnt/example"
}

variable "ec2_volume_label" {
  description = "Label do volume adicional"
  type        = string
  default     = "example_vol" # max: 16 caracteres
}

variable "ec2_volume_size_gb" {
  description = "Tamanho do volume adicional em GB"
  type        = number
  default     = 40
}

variable "instance_name" {
  description = "Tag Name da instância"
  type        = string
  default     = "example-server"
}

variable "instance_type" {
  description = "Tipo da instância EC2"
  type        = string
  default     = "t2.micro"
}

variable "key_name" {
  description = "Nome da Key Pair"
  default     = "example-key"
}

variable "key_path" {
  description = "Caminho da chave pública SSH"
  type        = string
  default     = "id_ed25519.pub"
}

variable "ssh_cidr" {
  description = "CIDR permitido para SSH"
  type        = string
  default     = "0.0.0.0/0"
}

variable "ssh_username" {
  description = "Usuário SSH da instância"
  type        = string
  default     = "devops"
}

variable "vpc_id" {
  description = "ID da VPC"
  type        = string
  default     = "vpc-0f5cbc8c491c269ee"
}

variable "vpc_subnet_id" {
  description = "Subnet pública da instância"
  type        = string
  default     = "subnet-0f898f79dabfbb7d5"
}
