# HA Proxy Server
output "prod_HAProxy_IP" {
    value = aws_instance.HAProxy1.private_ip
}
output "prod_HAProxy-backup_IP" {
    value = aws_instance.HAProxy-backup.private_ip
}