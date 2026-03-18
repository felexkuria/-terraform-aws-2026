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
  # Go to a writable directory
  cd /tmp

  # 1. Get the Token for IMDSv2
  TOKEN=$(curl -s -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")

  # 2. Get the Public IP
  INSTANCE_IP=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/public-ipv4)

  # 3. Create the HTML file (Note: We use a different delimiter here so bash replaces the IP)
  cat <<HTML > index.html
  <!DOCTYPE html>
  <html>
  <head>
      <title>EC2 Status</title>
      <style>
          body { background: #1a1a2e; color: #e94560; font-family: 'Segoe UI', sans-serif; display: flex; justify-content: center; align-items: center; height: 100vh; margin: 0; }
          .card { text-align: center; border: 2px solid #0f3460; padding: 50px; border-radius: 15px; background: #16213e; box-shadow: 0 10px 30px rgba(0,0,0,0.5); }
          h1 { color: #00d2ff; margin-bottom: 10px; }
          .ip { font-family: monospace; font-size: 1.5rem; color: #00ff88; background: #0f3460; padding: 10px; border-radius: 5px; }
      </style>
  </head>
  <body>
      <div class="card">
          <h1>EC2 Instance Live 🚀</h1>
          <p>Public IP Address:</p>
          <div class="ip">$${INSTANCE_IP:-Fetching...}</div>
      </div>
  </body>
  </html>
HTML

  # 4. Start the server (using 0.0.0.0 to ensure it listens externally)
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

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  
}