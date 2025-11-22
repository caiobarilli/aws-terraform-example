resource "aws_instance" "example-server" {
  ami               = data.aws_ami.selected.id
  instance_type     = var.instance_type
  availability_zone = var.availability_zone
  subnet_id         = var.vpc_subnet_id

  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.allow_ssh_http_https.id]
  key_name                    = aws_key_pair.example-key.key_name

  user_data                   = local.userdata
  user_data_replace_on_change = true

  tags = merge(
    var.default_tags,
    {
      Name = var.instance_name
    }
  )

  lifecycle {
    ignore_changes = [ami, key_name] # evita recrear instância ao mudar AMI ou key
  }
}

resource "aws_eip" "example-server" {
  instance = aws_instance.example-server.id
  tags     = var.default_tags
}

resource "aws_ebs_volume" "example-server" {
  type              = "gp3"
  availability_zone = var.availability_zone
  size              = var.ec2_volume_size_gb
  tags              = var.default_tags
  depends_on        = [aws_ebs_volume.example-server]

  lifecycle {
    prevent_destroy = false
    ignore_changes  = [availability_zone] # evita recriar volume ao mudar AZ da instância
  }
}

resource "aws_volume_attachment" "example-server" {
  device_name = var.device_name
  volume_id   = aws_ebs_volume.example-server.id
  instance_id = aws_instance.example-server.id

  depends_on = [
    aws_instance.example-server,
    aws_ebs_volume.example-server
  ]

  lifecycle {
    ignore_changes = [device_name]
  }
}
