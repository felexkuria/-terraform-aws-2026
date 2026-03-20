output "alb_dns_name" {
  value = aws_lb.web_server_alb.dns_name
}
output "alb_id" {
  value = aws_lb.web_server_alb.id
}