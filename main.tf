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
  source        = "./module/jenkins"
  instance_type_t2 = "t2.medium"
  keypair_name  = module.vpc.keypair
  prt_sn1       = module.vpc.prtsub1_id
  jenkins_name  = "${local.project-name}-jenkins"
  jenkins_sg    = module.vpc.jenkins_sg_id
  elb_name      = "${local.project-name}-elb"
  subnet_id2    = [module.vpc.pubsub1_id, module.vpc.pubsub2_id, module.vpc.pubsub3_id]
}