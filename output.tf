output "haproxy1" {
  value = module.haproxy-servers.prod_HAProxy_IP
}
output "haproxy2" {
  value = module.haproxy-servers.prod_HAProxy-backup_IP
}
output "worker_node" {
  value = module.worker_node.*.worker_ip
}

output "master_node" {
  value = module.master_node.master_ip
}
output "ansible_server" {
  value = module.ansible.ansible-ip
}

output "bastions_host" {
  value = module.bastions_host.bastion-ip
}

output "prometheus-lb" {
  value = module.prometheus_lb.prometheus-lb
}

output "grafana-lb" {
  value = module.grafana_lb.grafana-lb
}