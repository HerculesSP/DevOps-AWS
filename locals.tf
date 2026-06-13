locals {
  subnets = {
    public-1 = {
      cidr      = var.public_subnet_1_cidr
      az        = "${var.aws_region}${var.public_subnet_1_availability_zone}"
      name      = "${var.public_subnet_name}-${var.vpc_name}-${var.aws_region}${var.public_subnet_1_availability_zone}"
      public_ip = true
    }
    public-2 = {
      cidr      = var.public_subnet_2_cidr
      az        = "${var.aws_region}${var.public_subnet_2_availability_zone}"
      name      = "${var.public_subnet_name}-${var.vpc_name}-${var.aws_region}${var.public_subnet_2_availability_zone}"
      public_ip = true
    }

    app-1 = {
      cidr      = var.app_subnet_1_cidr
      az        = "${var.aws_region}${var.app_web_subnet_1_availability_zone}"
      name      = "${var.app_subnet_name}-${var.vpc_name}-${var.aws_region}${var.app_web_subnet_1_availability_zone}"
      public_ip = false
    }
    app-2 = {
      cidr      = var.app_subnet_2_cidr
      az        = "${var.aws_region}${var.app_web_subnet_2_availability_zone}"
      name      = "${var.app_subnet_name}-${var.vpc_name}-${var.aws_region}${var.app_web_subnet_2_availability_zone}"
      public_ip = false
    }

    web-1 = {
      cidr      = var.web_subnet_1_cidr
      az        = "${var.aws_region}${var.app_web_subnet_1_availability_zone}"
      name      = "${var.web_subnet_name}-${var.vpc_name}-${var.aws_region}${var.app_web_subnet_1_availability_zone}"
      public_ip = false
    }
    web-2 = {
      cidr      = var.web_subnet_2_cidr
      az        = "${var.aws_region}${var.app_web_subnet_2_availability_zone}"
      name      = "${var.web_subnet_name}-${var.vpc_name}-${var.aws_region}${var.app_web_subnet_2_availability_zone}"
      public_ip = false
    }

    db-1 = {
      cidr      = var.db_subnet_1_cidr
      az        = "${var.aws_region}${var.db_subnet_1_availability_zone}"
      name      = "${var.db_subnet_name}-${var.vpc_name}-${var.aws_region}${var.db_subnet_1_availability_zone}"
      public_ip = false
    }
    db-2 = {
      cidr      = var.db_subnet_2_cidr
      az        = "${var.aws_region}${var.db_subnet_2_availability_zone}"
      name      = "${var.db_subnet_name}-${var.vpc_name}-${var.aws_region}${var.db_subnet_2_availability_zone}"
      public_ip = false
    }
  }

  instances = {
    bastion = {
      name        = "bastion"
      subnet_id   = aws_subnet.subnets["public-1"].id
      public_ip   = true
      sg_ids      = [aws_security_group.bastion.id]
      volume_size = 10
      user_data   = "echo"
    }

    web-1 = {
      name        = "web-1"
      subnet_id   = aws_subnet.subnets["web-1"].id
      public_ip   = false
      sg_ids      = [aws_security_group.web.id]
      volume_size = 15
      user_data = templatefile("${path.module}/scripts/configWeb.sh.tpl", {
        html_content = file("${path.module}/scripts/index1a.html")
    }) }

    web-2 = {
      name        = "web-2"
      subnet_id   = aws_subnet.subnets["web-2"].id
      public_ip   = false
      sg_ids      = [aws_security_group.web.id]
      volume_size = 15
      user_data = templatefile("${path.module}/scripts/configWeb.sh.tpl", {
        html_content = file("${path.module}/scripts/index1b.html")
    }) }

    app-1 = {
      name        = "app-1"
      subnet_id   = aws_subnet.subnets["app-1"].id
      public_ip   = false
      sg_ids      = [aws_security_group.app.id]
      volume_size = 15
      user_data = templatefile("${path.module}/scripts/configApp.sh.tpl", {
        docker_image   = var.app_docker_image
        container_name = "app"
        db_private_ip  = aws_instance.instance_db.private_ip
        db_name        = var.db_name
        db_username    = var.db_username
        db_password    = var.db_password
        db_port        = "3306"
      })
    }

    app-2 = {
      name        = "app-2"
      subnet_id   = aws_subnet.subnets["app-2"].id
      public_ip   = false
      sg_ids      = [aws_security_group.app.id]
      volume_size = 15
      user_data = templatefile("${path.module}/scripts/configApp.sh.tpl", {
        docker_image   = var.app_docker_image
        container_name = "app"
        db_private_ip  = aws_instance.instance_db.private_ip
        db_name        = var.db_name
        db_username    = var.db_username
        db_password    = var.db_password
        db_port        = "3306"
      })
    }
  }
  db = {
    name        = "db"
    subnet_id   = aws_subnet.subnets["db-1"].id
    public_ip   = false
    sg_ids      = [aws_security_group.db.id]
    volume_size = 20
    user_data = templatefile("${path.module}/scripts/configDb.sh.tpl", {
      db_name     = var.db_name
      db_username = var.db_username
      db_password = var.db_password
      initdb_sql  = file("${path.module}/scripts/bd.sql")
    })
  }
  s3s = {
    raw = {
      name = "blobs"
    }
  }
}