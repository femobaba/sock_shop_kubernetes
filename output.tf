output "haproxy1" {
  value = module.haproxy-servers.prod_HAProxy_IP
}
output "haproxy2" {
  value = module.haproxy-servers.prod_HAProxy-backup_IP
}
output "worker_node" {
  value = module.worker_node.*.worker_ip
}
