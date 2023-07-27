 # Create VPC
resource "aws_vpc" "vpc" {
  cidr_block       = var.cidr_block_vpc
  instance_tenancy = var.vpc_instance_tenancy

  tags = {
    Name = var.vpc_name
  }
} 

# create public subnet 1
resource "aws_subnet" "pub_sn1" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.pub_sn1_cidr_block
  availability_zone = var.az1

  tags = {
    Name = var.pub_sn1_name
  }
}

 #create public subnet 2
resource "aws_subnet" "pub_sn2" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.pub_sn2_cidr_block
  availability_zone = var.az2
  tags = {
    Name = var.pub_sn2_name
  }
}

#create public subnet 3
resource "aws_subnet" "pub_sn3" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.pub_sn3_cidr_block
  availability_zone = var.az3
  tags = {
    Name = var.pub_sn3_name
  }
}

 #create private subnet 1
resource "aws_subnet" "prt_sn1" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.priv_sn1_cidr_block
  availability_zone = var.az1

  tags = {
    Name = var.prt_sn1_name
  }
}

# create private subnet 2
resource "aws_subnet" "prt_sn2" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.priv_sn2_cidr_block
  availability_zone = var.az2

  tags = {
    Name = var.prt_sn2_name
  }
}

# Create Private Subnet 03
resource "aws_subnet" "prt_sn3" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.priv_sn3_cidr_block
  availability_zone = var.az3

  tags = {
    Name = var.prt_sn3_name
  }
}

# create internet gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = var.igw_name
  }
}

 # create public route table
resource "aws_route_table" "pub_RT" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = var.all-cidr2
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = var.pub_RT_name
  }
}

 # create elastic IP
resource "aws_eip" "eip" {
  domain = "vpc"
}

 #create Nat gateway
resource "aws_nat_gateway" "nat-gateway" {
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.pub_sn1.id

  tags = {
    Name = var.nat-gateway_name
  }
}

  #create private subnet route table 
resource "aws_route_table" "prt_RT" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block     = var.all-cidr2
    nat_gateway_id = aws_nat_gateway.nat-gateway.id
  }

  tags = {
    Name = var.prt_RT_name
  }
}

# provision private subnet1 attached to private route table association
resource "aws_route_table_association" "prt_rta1" {
  subnet_id      = aws_subnet.prt_sn1.id
  route_table_id = aws_route_table.prt_RT.id
}

# provision private subnet2 attached to private route table
resource "aws_route_table_association" "prt_rta2" {
  subnet_id      = aws_subnet.prt_sn2.id
  route_table_id = aws_route_table.prt_RT.id
}

# Private subnet3 attached to private route table
resource "aws_route_table_association" "prt_rta3" {
  subnet_id      = aws_subnet.prt_sn3.id
  route_table_id = aws_route_table.prt_RT.id
}

# Route table association for public subnet 1
resource "aws_route_table_association" "pub_rta1" {
  subnet_id      = aws_subnet.pub_sn1.id
  route_table_id = aws_route_table.pub_RT.id
}

# Route table association for public subnet 2
resource "aws_route_table_association" "pub_rta2" {
  subnet_id      = aws_subnet.pub_sn2.id
  route_table_id = aws_route_table.pub_RT.id
}

# Route table association for public subnet 3
resource "aws_route_table_association" "pub_rta3" {
  subnet_id      = aws_subnet.pub_sn3.id
  route_table_id = aws_route_table.pub_RT.id
}

# Security Group
# Security Group for ansible - using the rule for least privilege permission.
resource "aws_security_group" "ansible_sg" {
  name        = var.ansible_sg_name
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description = "SSH"
    from_port   = var.port_ssh
    to_port     = var.port_ssh
    protocol    = "tcp"
    cidr_blocks = [var.all_cidr]
  }

  egress {
    from_port   = var.egress
    to_port     = var.egress
    protocol    = "-1"
    cidr_blocks = [var.all_cidr]
  }

  tags = {
    Name = var.ansible_sg_name
  }
}

# create security group for Jenkins - using the rule for least privilege permission.
resource "aws_security_group" "jenkins_sg" {
  name        = var.jenkins_sg_name
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description = "SSH"
    from_port   = var.port_ssh
    to_port     = var.port_ssh
    protocol    = "tcp"
    cidr_blocks = [var.all_cidr]
  }
  ingress {
    description = "Proxy Traffic"
    from_port   = var.port_jenkins
    to_port     = var.port_jenkins
    protocol    = "tcp"
    cidr_blocks = [var.all_cidr]
  }
  ingress {
    description = "allow lb  access"
    from_port   = var.port_http
    to_port     = var.port_http
    protocol    = "tcp"
    cidr_blocks = [var.all_cidr]
  }

  egress {
    from_port   = var.egress
    to_port     = var.egress
    protocol    = "-1"
    cidr_blocks = [var.all_cidr]
  }

  tags = {
    Name = var.jenkins_sg_name
  }
}

# create security group for Master_sg - using the rule for least privilege permission.
resource "aws_security_group" "master_sg" {
  name        = var.master_sg_name
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description = "SSH"
    from_port   = var.port_ssh
    to_port     = var.port_ssh
    protocol    = "tcp"
    cidr_blocks = [var.all_cidr]
  }
  ingress {
    description = "Proxy Traffic"
    from_port   = var.k8s_port
    to_port     = var.k8s_port2
    protocol    = "tcp"
    cidr_blocks = [var.all_cidr]
  }

  egress {
    from_port   = var.egress
    to_port     = var.egress
    protocol    = "-1"
    cidr_blocks = [var.all_cidr]
  }

  tags = {
    Name = var.master_sg_name
  }
}

# create security group for worker - using the rule for least privilege permission.
resource "aws_security_group" "worker_sg" {
  name        = var.worker_sg_name
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description = "SSH"
    from_port   = var.port_ssh
    to_port     = var.port_ssh
    protocol    = "tcp"
    cidr_blocks = [var.all_cidr]
  }
  ingress {
    description = "Proxy Traffic"
    from_port   = var.k8s_worker_port
    to_port     = var.k8s_worker_port
    protocol    = "tcp"
    cidr_blocks = [var.all_cidr]
  }
  ingress {
    description = "allow lb access"
    from_port   = var.k8s_worker_port2
    to_port     = var.k8s_worker_port3
    protocol    = "tcp"
    cidr_blocks = [var.all_cidr]
  }

  egress {
    from_port   = var.egress
    to_port     = var.egress
    protocol    = "-1"
    cidr_blocks = [var.all_cidr]
  }

  tags = {
    Name = var.worker_sg_name
  }
}


#KEYPAIR
# RSA key of size 4096 bits 
# This TLS resource creates our Key Pair. 
# This will generate an Instant Key and make our codes more dynamic.
resource "tls_private_key" "us_teamkeypair" {
  algorithm = "RSA"
  rsa_bits  = "4096"
}

# Creation of path of our key in our local machine
resource "local_file" "keypair" {
  content         = tls_private_key.us_teamkeypair.private_key_pem
  filename        = "us-team-keypair.pem"
  file_permission = "600"
}

#Creation of Keypair
resource "aws_key_pair" "us_keypair" {
  key_name   = var.key_name
  public_key = tls_private_key.us_teamkeypair.public_key_openssh
}