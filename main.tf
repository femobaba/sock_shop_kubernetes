provider "aws" {
  profile = "Groupaccess"
  region  = "us-west-2"
}

locals {
  project-name = "us-team-sock-shop"
  env1         = "stage"
  env2         = "prod"
}

# Infrastructure module
module "vpc" {
  source               = "./module/vpc"
  vpc_name             = "${local.project-name}-vpc"
  pub_sn1_name         = "${local.project-name}-pub-sn1"
  pub_sn2_name         = "${local.project-name}-pub-sn2"
  pub_sn3_name         = "${local.project-name}-pub-sn3"
  prt_sn1_name         = "${local.project-name}-prt-sn1"
  prt_sn2_name         = "${local.project-name}-prt-sn2"
  prt_sn3_name         = "${local.project-name}-prt-sn3"
  vpc_instance_tenancy = "default"
  all-cidr2            = "0.0.0.0/0"
  cidr_block_vpc       = "10.0.0.0/16"
  pub_sn1_cidr_block   = "10.0.1.0/24"
  pub_sn2_cidr_block   = "10.0.2.0/24"
  pub_sn3_cidr_block   = "10.0.3.0/24"
  priv_sn1_cidr_block  = "10.0.4.0/24"
  priv_sn2_cidr_block  = "10.0.5.0/24"
  priv_sn3_cidr_block  = "10.0.6.0/24"
  az1                  = "us-west-2a"
  az2                  = "us-west-2b"
  az3                  = "us-west-2c"
  igw_name             = "${local.project-name}-igw"
  nat-gateway_name     = "${local.project-name}-ngw"
  prt_RT_name          = "${local.project-name}-prt-rt"
  pub_RT_name          = "${local.project-name}-pub-rt"

  #Key name
  key_name = "${local.project-name}-keypair"

  #Security Group
  ansible_sg_name  = "${local.project-name}-ansible-sg"
  jenkins_sg_name  = "${local.project-name}-jenkins-sg"
  master_sg_name   = "${local.project-name}-master-sg"
  worker_sg_name   = "${local.project-name}-worker-sg"
  port_ssh         = 22
  port_http        = 80
  port_jenkins     = 8080
  k8s_port         = 0
  k8s_port2        = 65535
  k8s_worker_port  = 10250
  k8s_worker_port2 = 30000
  k8s_worker_port3 = 32767
  all_cidr         = "0.0.0.0/0"
  egress           = 0
}
module "jenkins" {
  source           = "./module/jenkins"
  instance_type_t2 = "t2.medium"
  keypair_name     = module.vpc.keypair
  prt_sn1          = module.vpc.prtsub1_id
  jenkins_name     = "${local.project-name}-jenkins"
  jenkins_sg       = module.vpc.jenkins_sg_id
  elb_name         = "${local.project-name}-elb"
  subnet_id2       = [module.vpc.pubsub1_id, module.vpc.pubsub2_id, module.vpc.pubsub3_id]
}
module "bastions_host" {
  source              = "./module/bastion"
  bastion-name        = "${local.project-name}-bastion"
  ubuntu_ami          = "ami-03f65b8614a860c29"
  instance_type_micro = "t2.micro"
  subnet_id           = module.vpc.pubsub1_id
  security_group      = module.vpc.ansible_sg_id
  keypair_name        = module.vpc.keypair
  private_key         = module.vpc.private-key
}
#create haproxy module 
module "haproxy-servers" {
  source        = "./module/haproxy"
  keypair       = module.vpc.keypair
  ami           = "ami-03f65b8614a860c29"
  instance_type = "t2.medium"
  prtsub1_id    = module.vpc.prtsub1_id
  prtsub2_id    = module.vpc.prtsub3_id
  HAproxy_sg    = module.vpc.master_sg_id
  master1       = module.master_node.master_ip[0]
  master2       = module.master_node.master_ip[1]
  master3       = module.master_node.master_ip[2]
  master4       = module.master_node.master_ip[0]
  master5       = module.master_node.master_ip[1]
  master6       = module.master_node.master_ip[2]
  name-tags     = "${local.project-name}-haproxy1"
  name-tags2    = "${local.project-name}-haproxy-backup"
}
#create worker_node
module "worker_node" {
  source         = "./module/worker_node"
  ubuntu_ami     = "ami-03f65b8614a860c29"
  instance_type  = "t2.medium"
  worker-node-sg = module.vpc.master_sg_id
  subnet_id      = [module.vpc.prtsub1_id, module.vpc.prtsub2_id, module.vpc.prtsub3_id]
  keypair_name   = module.vpc.keypair
  instance_count = 3
  instance_name  = "${local.project-name}-worker_node"
}

#master_node module
module "master_node" {
  source         = "./module/master_node"
  ubuntu_ami     = "ami-03f65b8614a860c29"
  instance_type  = "t2.medium"
  master-node-sg = module.vpc.master_sg_id
  subnet_id      = [module.vpc.prtsub1_id, module.vpc.prtsub2_id, module.vpc.prtsub3_id]
  keypair_name   = module.vpc.keypair
  instance_count = 3
  instance_name  = "${local.project-name}-master_node"
}
#creating ansible server
module "ansible" {
  source         = "./module/ansible"
  ami            = "ami-03f65b8614a860c29"
  instance_type  = "t2.micro"
  subnet_id      = module.vpc.prtsub1_id
  ansible-sg-id  = module.vpc.ansible_sg_id
  keys           = module.vpc.keypair
  prv_key        = module.vpc.private-key
  HAproxy1_IP    = module.haproxy-servers.prod_HAProxy_IP
  HAproxy2_IP    = module.haproxy-servers.prod_HAProxy-backup_IP
  master1_IP     = module.master_node.master_ip[0]
  master2_IP     = module.master_node.master_ip[1]
  master3_IP     = module.master_node.master_ip[2]
  worker1_IP     = module.worker_node.worker_ip[0]
  worker2_IP     = module.worker_node.worker_ip[1]
  worker3_IP     = module.worker_node.worker_ip[2]
  bastion-host   = module.bastions_host.bastion-ip
  ansible_server = "${local.project-name}-ansible-server"
}

# creating route53
module "route53" {
  source                        = "./module/route-53"
  domain_name                   = "praisepeace.link"
  domain_name2                  = "*.praisepeace.link"
  grafana_domain_hosted_zone    = "grafana.praisepeace.link"
  prometheus_domain_hosted_zone = "prometheus.praisepeace.link"
  stage_domain_hosted_zone      = "stage.praisepeace.link"
  prod_domain_name              = "prod.praisepeace.link"
  prometheus-lb-dns-name        = module.prometheus_lb.prometheus-lb
  prometheus-lb-zone-id         = module.prometheus_lb.prometheus-zone_id
  grafana-lb-dns-name           = module.grafana_lb.grafana-lb
  grafana-lb-zone-id            = module.grafana_lb.grafana-zone_id
  prod-lb-dns-name              = module.prod_lb.prod-dns-name
  prod-lb-zone-id               = module.prod_lb.prod-zone-id
  stage-lb-dns-name             = module.stage_lb.stage-dns-name
  stage-lb-zone-id              = module.stage_lb.stage-zone-id
}