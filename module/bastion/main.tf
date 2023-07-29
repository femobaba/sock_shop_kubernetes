#create bastions_host
resource "aws_instance" "us-team-bastion" {
  ami                         = var.ubuntu_ami
  instance_type               = var.instance_type_micro
  subnet_id                   = var.subnet_id
  associate_public_ip_address = true
  vpc_security_group_ids      = [var.security_group]
  key_name                    = var.keypair_name
  user_data                   = <<-EOF
#!/bin/bash
echo "pubkeyAcceptedkeyTypes=+ssh-rsa" >> /etc/ssh/sshd_config.d/10-insecure-rsa-keysig.conf
systemctl reload sshd
echo "${var.private_key}" >> /home/ubuntu/.ssh/id_rsa
chown ubuntu /home/ubuntu/.ssh/id_rsa
chgrp ubuntu /home/ubuntu/.ssh/id_rsa
chmod 600 /home/ubuntu/.ssh/id_rsa
sudo hostnamectl set-hostname bastion
EOF
  tags = {
    Name = var.bastion-name
  }
}