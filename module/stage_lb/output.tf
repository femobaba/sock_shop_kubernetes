output "stage-dns-name" {
  value = aws_lb.stage-lb.dns_name
}

output "stage-zone-id" {
  value = aws_lb.stage-lb.zone_id
}