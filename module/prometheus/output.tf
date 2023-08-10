output "prometheus-lb" {
    value = aws_lb.prometheus-lb.dns_name
}

output "prometheus-zone_id" {
    value = aws_lb.prometheus-lb.zone_id
}