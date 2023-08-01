#Creating Master node
resource "aws_instance" "master_node" {
  ami                         = var.ubuntu_ami
  instance_type               = var.instance_type
  subnet_id                   = element(var.subnet_id, count.index)
  vpc_security_group_ids      = [var.master-node-sg]
  key_name                    = var.keypair_name
  count                       = var.instance_count

  tags = {
    Name = "${var.instance_name}${count.index}"
  }
}