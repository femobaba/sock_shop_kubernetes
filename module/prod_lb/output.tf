output "prod-dns-name" {
  value = aws_lb.prod-lb.dns_name
}

output "prod-zone-id" {
  value = aws_lb.prod-lb.zone_id
}