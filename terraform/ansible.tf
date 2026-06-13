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

resource "local_file" "ansible_app_infra_vars" {
  filename        = "${path.module}/../ansible/inventories/production/group_vars/all.yml"
  file_permission = "0644"

  content = yamlencode({
    db_host = aws_instance.instance_db.private_ip
  })
}

resource "null_resource" "run_ansible" {
  depends_on = [
    local_file.ansible_inventory,
    local_file.ansible_app_infra_vars,
    aws_instance.instances,
    aws_instance.instance_db
  ]

  provisioner "local-exec" {
    working_dir = "${path.module}/../ansible"
    command     = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i inventories/production/hosts.ini playbooks/app.yml"
  }
}