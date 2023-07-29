#Create HA Proxy Server
resource "aws_instance" "HAProxy1" {
  ami                         = var.ami
  instance_type               = var.instance_type
  subnet_id                   = var.prtsub1_id
  vpc_security_group_ids      = [var.HAproxy_sg]
  key_name                    = var.keypair
  user_data                   = templatefile("./module/haproxy/data.sh",{
    master1=var.master1,
    master2=var.master2,
    master3=var.master3
  })

    tags = {
    Name = var.name-tags
  }
}

#Create HA Proxy Server
resource "aws_instance" "HAProxy-backup" {
  ami                         = var.ami
  instance_type               = var.instance_type
  subnet_id                   = var.prtsub2_id
  vpc_security_group_ids      = [var.HAproxy_sg]
  key_name                    = var.keypair
  user_data                   = templatefile("./module/haproxy/data2.sh",{
    master4=var.master4,
    master5=var.master5,
    master6=var.master6
  })

    tags = {
    Name = var.name-tags2
  }
}