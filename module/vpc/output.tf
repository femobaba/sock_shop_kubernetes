#Infrastructure
output "vpc_id" {
  value = aws_vpc.vpc.id
}
output "pubsub1_id" {
  value = aws_subnet.pub_sn1.id
}
output "pubsub2_id" {
  value = aws_subnet.pub_sn2.id
}
output "pubsub3_id" {
  value = aws_subnet.pub_sn3.id
}
output "prtsub1_id" {
  value = aws_subnet.prt_sn1.id
}
output "prtsub2_id" {
  value = aws_subnet.prt_sn2.id
}
output "prtsub3_id" {
  value = aws_subnet.prt_sn3.id
}

#keypair
output "keypair" {
  value = aws_key_pair.us_keypair.id
}
output "private-key" {
  value = tls_private_key.us_teamkeypair.private_key_pem
}

#Security Group
output "jenkins_sg_id" {
  value = aws_security_group.jenkins_sg.id
}
output "ansible_sg_id" {
  value = aws_security_group.ansible_sg.id
}
output "worker_server_sg_id" {
  value = aws_security_group.worker_sg.id
}
output "master_sg_id" {
  value = aws_security_group.master_sg.id
}