# Jenkins Server
resource "aws_instance" "jenkins" {
  ami                    = "ami-04752fceda1274920" # Amazon Linux 2023
  instance_type          = "c7i-flex.large"  # Need more RAM for Jenkins
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.common.id]

  user_data = <<-EOF
    #!/bin/bash
    yum update -y
    
    # Install Docker
    yum install -y docker
    systemctl start docker
    systemctl enable docker
    usermod -a -G docker ec2-user
    
    # Install Java
    yum install -y java-17-amazon-corretto-devel
    
    # Install Jenkins
    wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
    rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
    yum install -y jenkins
    systemctl start jenkins
    systemctl enable jenkins
    
    # Install git
    yum install -y git
    
    # Install kubectl
    curl -LO "https://dl.k8s.io/release/v1.29.0/bin/linux/amd64/kubectl"
    chmod +x kubectl
    mv kubectl /usr/local/bin/
    
    echo "Jenkins setup complete"
  EOF

  tags = {
    Name = "jenkins-server"
  }
}
