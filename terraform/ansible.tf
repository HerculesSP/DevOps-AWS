resource "local_file" "ansible_inventory" {
  filename        = "${path.module}/../ansible/inventories/production/hosts.ini"
  file_permission = "0644"

  content = templatefile("${path.module}/scripts/hosts.ini.tftpl", {
    bastion_public_ip = aws_instance.instances["bastion"].public_ip
    app_1_private_ip  = aws_instance.instances["app-1"].private_ip
    app_2_private_ip  = aws_instance.instances["app-2"].private_ip
    private_key_path  = "../terraform/${var.key_name}.pem"
  })
}

resource "local_file" "ansible_all_vars" {
  filename        = "${path.module}/../ansible/inventories/production/group_vars/all.yml"
  file_permission = "0644"

  content = yamlencode({
    db_host = aws_db_instance.instance_db.address
    db_port     = 3306
    db_name     = var.db_name
    db_username = var.db_username
    db_password = var.db_password
  })
}

resource "local_file" "ansible_app_vars" {
  filename        = "${path.module}/../ansible/inventories/production/group_vars/app.yml"
  file_permission = "0644"

  content = yamlencode({
    app_image   = var.app_docker_image
  })
}

resource "null_resource" "configurando_db" {
  depends_on = [
    local_file.ansible_inventory,
    local_file.ansible_all_vars,
    aws_db_instance.instance_db
  ]

  provisioner "local-exec" {
    working_dir = "${path.module}/../ansible"
    command     = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i inventories/production/hosts.ini playbooks/db.yml"
  }
}

resource "null_resource" "configurando_app" {
  depends_on = [
    aws_instance.instances,
    null_resource.configurando_db
  ]

  provisioner "local-exec" {
    working_dir = "${path.module}/../ansible"
    command     = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i inventories/production/hosts.ini playbooks/app.yml"
  }
}