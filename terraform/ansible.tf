resource "local_file" "ansible_inventory" {
  filename        = "${path.module}/../ansible/inventories/production/hosts.ini"
  file_permission = "0644"

  content = templatefile("${path.module}/scripts/hosts.ini.tftpl", {
    bastion_public_ip = aws_instance.instances["bastion"].public_ip
    app_1_private_ip  = aws_instance.instances["app-1"].private_ip
    app_2_private_ip  = aws_instance.instances["app-2"].private_ip
    private_key_path  = "${path.module}/${var.key_name}.pem"
  })
}

resource "local_file" "ansible_app_infra_vars" {
  filename        = "${path.module}/../ansible/inventories/production/group_vars/app_infra.yml"
  file_permission = "0644"

  content = yamlencode({
    db_host = aws_instance.instance_db.private_ip
  })
}