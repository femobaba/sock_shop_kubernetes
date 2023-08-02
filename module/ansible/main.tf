# Creating Ansible 
resource "aws_instance" "ansible_server" {
  ami                         = var.ami
  instance_type               = var.instance_type
  key_name                    = var.keys
  vpc_security_group_ids      = [var.ansible-sg-id]
  subnet_id                   = var.subnet_id
  user_data                   = templatefile("./module/ansible/userdata.sh", {
    prv_key=var.prv_key,
    HAproxy1_IP=var.HAproxy1_IP,
    HAproxy2_IP=var.HAproxy2_IP,
    master1_IP=var.master1_IP,
    master2_IP=var.master2_IP,
    master3_IP=var.master3_IP,
    worker1_IP=var.worker1_IP,
    worker2_IP=var.worker2_IP,
    worker3_IP=var.worker3_IP
  })

  tags = {
    Name = var.ansible_server
  }
}

#create null resource ansible server
resource "null_resource" "copy-playbooks" {
  connection {
    type                = "ssh"
    host                = aws_instance.ansible_server.private_ip
    user                = "ubuntu"
    private_key         = var.prv_key
    bastion_host        = var.bastion-host
    bastion_user        = "ubuntu"
    bastion_private_key = var.prv_key
  }
  provisioner "file" {
    source      = "./module/ansible/playbooks"
    destination = "/home/ubuntu/playbooks"
  }
}