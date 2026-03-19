output "name" {
  value = aws_instance.web_server.id
}
output "public_ip" {
  value = aws_instance.web_server.public_ip
}
output "private_ip" {
  value = aws_instance.web_server.private_ip
}
output "sg_id" {
  value = aws_security_group.web_server_sg.id
}