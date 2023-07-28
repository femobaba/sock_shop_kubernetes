output "jenkins" {
  value = aws_instance.jenkins.id
}
output "jenkins_ip" {
  value = aws_instance.jenkins.private_ip
}
output "jenkins-dns_name" {
  value = aws_elb.jenkins_lb.dns_name
}