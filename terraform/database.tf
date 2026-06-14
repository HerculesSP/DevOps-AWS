resource "aws_db_instance" "instance_db" {
  identifier             = "app-db"
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = "db.t4g.small"
  allocated_storage      = 20
  storage_type           = "gp3"
  storage_encrypted      = true

  db_name                = var.db_name
  username               = var.db_username
  password               = var.db_password

  db_subnet_group_name   = aws_db_subnet_group.db.name
  vpc_security_group_ids = [aws_security_group.db.id]

  publicly_accessible    = false
  multi_az               = true
  skip_final_snapshot    = true
  deletion_protection    = false

  backup_retention_period = 7

  tags = {
    Name = "app-db"
  }
}