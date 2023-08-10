output "k8s-cert" {
  value = aws_acm_certificate.k8s-cert.arn
}