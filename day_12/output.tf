#Step 11 create output
output "web_server_lb_dns_name" {
  description = "The DNS name of the web server load balancer"
  value = aws_lb.web_server_lb.dns_name
}
#Step 12 create output
output "web_server_asg_name" {
  description = "The name of the web server asg"
  value = aws_autoscaling_group.web_server_asg.name
}
#Step 13 create output
output "web_server_asg_policy_name" {
  description = "The name of the web server asg policy"
  value = aws_autoscaling_policy.web_server_asg_policy.name
}
# #Step 14 create output
# output "web_server_asg_attachment_id" {
#   description = "The ID of the web server asg attachment"
#   value = aws_autoscaling_attachment.asg_attachment.id
# }