locals {
  jenkins-userdata = <<-EOF
#!/bin/bash
sudo yum update -y
sudo yum upgrade -y
sudo yum install wget -y
sudo yum install git -y
sudo yum install java-11-openjdk -y
sudo wget https://get.jenkins.io/redhat/jenkins-2.411-1.1.noarch.rpm
sudo rpm -ivh jenkins-2.411-1.1.noarch.rpm
sudo yum update -y
sudo yum install jenkins -y
sudo systemctl start jenkins
sudo systemctl enable jenkins
sudo hostnamectl set-hostname Jenkins
# #!/bin/bash
# sudo apt update -y
# sudo apt install openjdk-17-jre -y
# curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | sudo tee \
#   /usr/share/keyrings/jenkins-keyring.asc > /dev/null
# echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
#   https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
#   /etc/apt/sources.list.d/jenkins.list > /dev/null
# sudo apt-get update -y
# sudo apt-get install jenkins -y
# sudo hostnamectl set-hostname Jenkins
EOF
}