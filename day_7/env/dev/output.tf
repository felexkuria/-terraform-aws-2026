output "aws_instance_public_ip" {
  value = aws_instance.example.public_ip
}
output "aws_security_group_id" {
  value = aws_security_group.example_sg.id
}
output "aws_instance_id" {
  value = aws_instance.example.id
  }
output "aws_instance_name" {
  value = aws_instance.example.tags.Name
  }
  







