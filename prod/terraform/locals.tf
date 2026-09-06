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
    }

    web-1 = {
      name        = "web-1"
      subnet_id   = aws_subnet.subnets["web-1"].id
      public_ip   = false
      sg_ids      = [aws_security_group.web.id]
      volume_size = 15
    }

    web-2 = {
      name        = "web-2"
      subnet_id   = aws_subnet.subnets["web-2"].id
      public_ip   = false
      sg_ids      = [aws_security_group.web.id]
      volume_size = 15
    }

    app-1 = {
      name        = "app-1"
      subnet_id   = aws_subnet.subnets["app-1"].id
      public_ip   = false
      sg_ids      = [aws_security_group.app.id]
      volume_size = 15
    }

    app-2 = {
      name        = "app-2"
      subnet_id   = aws_subnet.subnets["app-2"].id
      public_ip   = false
      sg_ids      = [aws_security_group.app.id]
      volume_size = 15
    }
  }
  s3s = {
    blobs = {
      name = "blobs"
    }
  }
}