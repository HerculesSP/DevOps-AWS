resource "aws_instance" "instance_db" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = local.db.subnet_id
  vpc_security_group_ids      = local.db.sg_ids
  key_name                    = var.key_name
  associate_public_ip_address = local.db.public_ip
  user_data                   = local.db.user_data

  root_block_device {
    volume_size           = local.db.volume_size
    volume_type           = "gp3"
    encrypted             = true
    delete_on_termination = true
  }

  tags = {
    Name = local.db.name
  }
}