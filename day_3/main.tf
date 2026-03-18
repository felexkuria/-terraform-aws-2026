# provider "aws" {
#   region = "us-east-1"
# }
# resource "aws_instance" "web_server" {
#   ami           = "ami-0ecb62995f68bb549"
#   instance_type = "t3.micro"
#   tags={Name="Web_Server"}
# }

provider "aws" {
  region="us-east-1"
}
resource "aws_instance" "web_server" {
  ami = "ami-0ecb62995f68bb549"
  instance_type="t3.small"
  tags={Name="Web_Server"}
  vpc_security_group_ids = [aws_security_group.web_server_sg.id]

  user_data = <<-EOF
 #!/bin/bash
# Fetch the Private IP (or Public IP by changing the URL)
TOKEN=$(curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
INSTANCE_IP=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" -s http://169.254.169.254/latest/meta-data/local-ipv4)

cat <<HTML > index.html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>EC2 Status</title>
    <style>
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            height: 100vh;
            margin: 0;
            display: flex;
            justify-content: center;
            align-items: center;
            color: #2d3436;
        }
        .card {
            background: white;
            padding: 2rem;
            border-radius: 15px;
            box-shadow: 0 10px 25px rgba(0,0,0,0.2);
            text-align: center;
            width: 350px;
        }
        .icon {
            font-size: 50px;
            margin-bottom: 10px;
        }
        h1 {
            margin: 0;
            font-size: 1.5rem;
            color: #4b6cb7;
        }
        .ip-box {
            background: #f1f2f6;
            padding: 15px;
            border-radius: 8px;
            margin-top: 20px;
            font-family: 'Courier New', Courier, monospace;
            font-weight: bold;
            font-size: 1.2rem;
            border: 1px solid #dfe4ea;
        }
        .status {
            display: inline-block;
            margin-top: 15px;
            padding: 5px 12px;
            background: #27ae60;
            color: white;
            border-radius: 20px;
            font-size: 0.8rem;
            text-transform: uppercase;
        }
    </style>
</head>
<body>
    <div class="card">
        <div class="icon">☁️</div>
        <h1>EC2 Instance</h1>
        <p>Private IP Address:</p>
        <div class="ip-box">$INSTANCE_IP</div>
        <div class="status">Online</div>
    </div>
</body>
</html>
HTML

# Start the server on port 8080
nohup busybox httpd -f -p 8080 &
  EOF
  user_data_replace_on_change = true
}
resource "aws_security_group" "web_server_sg" {
  name="web_server_sg"
  ingress {
    from_port=8080
    to_port=8080
    protocol="tcp"
    cidr_blocks=["0.0.0.0/0"]
  }
  
  
}