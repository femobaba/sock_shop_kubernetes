output "grafana-lb" {
    value = aws_lb.grafana-lb.dns_name
}

output "grafana-zone_id" {
    value = aws_lb.grafana-lb.zone_id
}