output "jenkins_ip" {
  value = aws_instance.jenkins.public_ip
}

output "app_server_ip" {
  value = aws_instance.app.public_ip
}

output "monitoring_server_ip" {
  value = aws_instance.monitoring.public_ip
}

output "app_server_private_ip" {
  value = aws_instance.app.private_ip
}

output "jenkins_private_ip" {
  value = aws_instance.jenkins.private_ip
}