# Monitoring Server (Prometheus + Grafana)
resource "aws_instance" "monitoring" {
  ami                    = "ami-04752fceda1274920"
  instance_type          = "c7i-flex.large"  # Need more RAM for monitoring
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
    
    # Install git
    yum install -y git
    
    # Create docker-compose.yml for monitoring
    mkdir -p /home/ec2-user/monitoring
    cat > /home/ec2-user/monitoring/docker-compose.yml << 'COMPOSE'
version: '3'
services:
  prometheus:
    image: prom/prometheus:latest
    container_name: prometheus
    ports:
      - "9090:9090"
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml
      - prometheus_data:/prometheus
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
    restart: unless-stopped
    networks:
      - monitoring

  grafana:
    image: grafana/grafana:latest
    container_name: grafana
    ports:
      - "3000:3000"
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=admin
    volumes:
      - grafana_data:/var/lib/grafana
    restart: unless-stopped
    networks:
      - monitoring

  node-exporter:
    image: prom/node-exporter:latest
    container_name: node-exporter
    ports:
      - "9100:9100"
    restart: unless-stopped
    networks:
      - monitoring

volumes:
  prometheus_data:
  grafana_data:

networks:
  monitoring:
    driver: bridge
COMPOSE

    # Create prometheus config
    cat > /home/ec2-user/monitoring/prometheus.yml << 'PROM'
global:
  scrape_interval: 15s
  evaluation_interval: 15s

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']

  - job_name: 'node'
    static_configs:
      - targets: ['localhost:9100']

  - job_name: 'app-server'
    static_configs:
      - targets: ['APP_SERVER_IP:9100']

  - job_name: 'jenkins'
    static_configs:
      - targets: ['JENKINS_SERVER_IP:9100']
PROM

    chown -R ec2-user:ec2-user /home/ec2-user/monitoring
    echo "Monitoring server setup complete"
  EOF

  tags = {
    Name = "monitoring-server"
  }
}