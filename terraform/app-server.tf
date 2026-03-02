# App Server with k3s (lightweight Kubernetes)
resource "aws_instance" "app" {
  ami                    = "ami-04752fceda1274920"
  instance_type          = "c7i-flex.large"  # Need more RAM for k3s
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
    
    # Install k3s (lightweight Kubernetes)
    curl -sfL https://get.k3s.io | sh -
    systemctl start k3s
    systemctl enable k3s
    
    # Copy kubeconfig for ec2-user
    mkdir -p /home/ec2-user/.kube
    cp /etc/rancher/k3s/k3s.yaml /home/ec2-user/.kube/config
    chown -R ec2-user:ec2-user /home/ec2-user/.kube
    
    # Install git
    yum install -y git
    
    echo "App server with k3s ready"
  EOF

  tags = {
    Name = "app-server"
  }
}