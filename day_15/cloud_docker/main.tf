# --- Part 2: The Cloud Orchestra (Terraform) ---

# --- Provider Configuration ---
# Tell Terraform we want to work with AWS and which region.
# This is like telling our architect which country/state to build in!
provider "aws" {
  region = "us-east-1" # Feel free to change this to your preferred region!
}

# --- Security Group (Firewall Rules) ---
# This is like defining the "doors and windows" of our house.
# We want to allow web traffic (HTTP on port 80) and SSH (port 22) from anywhere.
resource "aws_security_group" "web_sg" {
  name        = "web-server-security-group"
  description = "Allow HTTP and SSH traffic"

  ingress { # Incoming rules (HTTP)
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow from all IP addresses
  }

  ingress { # Incoming rules (SSH for debugging)
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress { # Outgoing rules (allow all outbound traffic)
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # -1 means all protocols
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "WebSecurityGroup"
  }
}

# --- EC2 Instance (Our Server!) ---
# This is our actual server, the "house" where Docker will live!
resource "aws_instance" "docker_host" {
  ami           = "ami-053b0d53c279acc90" # Ubuntu 22.04 LTS (HVM) in us-east-1
  instance_type = "t2.micro"           # A small, cost-effective instance type.

  security_groups = [aws_security_group.web_sg.name] # Attach our security group

  # --- THE MAGIC user_data SCRIPT! ---
  # This is the "instructions" we give to the server *as it's being launched*.
  # We are combining the root README instructions with our Beautiful Website logic!
  user_data = <<-EOF
              #!/bin/bash
              sudo apt-get update -y
              sudo apt-get install -y docker.io # Install Docker
              sudo systemctl start docker
              sudo systemctl enable docker

              # Create a folder for our application
              mkdir -p /home/ubuntu/app
              cd /home/ubuntu/app

              # Re-create our "Beautiful Website" files
              cat << 'INDEX' > index.html
              <!DOCTYPE html>
              <html lang="en">
              <head>
                  <meta charset="UTF-8">
                  <meta name="viewport" content="width=device-width, initial-scale=1.0">
                  <title>CS50 Lab: Dockerized Perfection</title>
                  <link rel="stylesheet" href="style.css">
                  <link rel="preconnect" href="https://fonts.googleapis.com">
                  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
                  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;600;800&display=swap" rel="stylesheet">
              </head>
              <body>
                  <div class="background-blobs">
                      <div class="blob blob-1"></div>
                      <div class="blob blob-2"></div>
                      <div class="blob blob-3"></div>
                  </div>
                  
                  <main class="glass-container">
                      <header>
                          <div class="badge">Day 15: Docker Lab</div>
                          <h1>THIS IS <span>DOCKER</span>.</h1>
                          <p class="subtitle">You have successfully containerized your first web application.</p>
                      </header>

                      <section class="status-card">
                          <div class="status-indicator">
                              <div class="pulse"></div>
                              <span>Container Status: <strong>LIVE (AWS Cloud)</strong></span>
                          </div>
                          <div class="stats">
                              <div class="stat">
                                  <span class="label">Architecture</span>
                                  <span class="value">Isolated</span>
                              </div>
                              <div class="stat">
                                  <span class="label">Efficiency</span>
                                  <span class="value">100%</span>
                              </div>
                              <div class="stat">
                                  <span class="label">Environment</span>
                                  <span class="value">AWS EC2</span>
                              </div>
                          </div>
                      </section>

                      <footer>
                          <p>Congratulations! You've just orchestrated a symphony of infrastructure in the cloud.</p>
                          <div class="social-links">
                              <a href="#" class="btn-primary">Learn More</a>
                              <a href="#" class="btn-secondary">View Documentation</a>
                          </div>
                      </footer>
                  </main>
              </body>
              </html>
              INDEX

              cat << 'CSS' > style.css
              :root {
                  --primary: #4F46E5;
                  --primary-light: #818CF8;
                  --background: #0F172A;
                  --text-main: #F8FAFC;
                  --text-muted: #94A3B8;
                  --glass-bg: rgba(255, 255, 255, 0.03);
                  --glass-border: rgba(255, 255, 255, 0.1);
                  --glow-start: #3B82F6;
                  --glow-end: #8B5CF6;
              }

              * {
                  margin: 0;
                  padding: 0;
                  box-sizing: border-box;
              }

              body {
                  font-family: 'Inter', sans-serif;
                  background-color: var(--background);
                  color: var(--text-main);
                  display: flex;
                  justify-content: center;
                  align-items: center;
                  min-height: 100vh;
                  overflow: hidden;
                  line-height: 1.6;
              }

              /* Background Animations */
              .background-blobs {
                  position: fixed;
                  top: 0;
                  left: 0;
                  right: 0;
                  bottom: 0;
                  z-index: -1;
                  filter: blur(80px);
              }

              .blob {
                  position: absolute;
                  border-radius: 50%;
                  opacity: 0.5;
                  animation: float 20s infinite ease-in-out;
              }

              .blob-1 {
                  width: 400px;
                  height: 400px;
                  background: radial-gradient(circle, var(--glow-start) 0%, transparent 70%);
                  top: -100px;
                  left: -100px;
              }

              .blob-2 {
                  width: 600px;
                  height: 600px;
                  background: radial-gradient(circle, var(--glow-end) 0%, transparent 70%);
                  bottom: -150px;
                  right: -150px;
                  animation-delay: -5s;
              }

              .blob-3 {
                  width: 300px;
                  height: 300px;
                  background: radial-gradient(circle, var(--primary) 0%, transparent 70%);
                  top: 50%;
                  left: 55%;
                  transform: translate(-50%, -50%);
                  animation-delay: -10s;
              }

              @keyframes float {
                  0%, 100% { transform: translate(0, 0) scale(1); }
                  33% { transform: translate(30px, -50px) scale(1.1); }
                  66% { transform: translate(-20px, 20px) scale(0.9); }
              }

              /* Glassmorphism Container */
              .glass-container {
                  background: var(--glass-bg);
                  backdrop-filter: blur(20px);
                  border: 1px solid var(--glass-border);
                  padding: 3rem;
                  border-radius: 24px;
                  box-shadow: 0 8px 32px 0 rgba(0, 0, 0, 0.37);
                  width: 90%;
                  max-width: 600px;
                  text-align: center;
                  z-index: 10;
              }

              /* Badge System */
              .badge {
                  background: rgba(79, 70, 229, 0.1);
                  color: var(--primary-light);
                  font-size: 0.75rem;
                  font-weight: 800;
                  text-transform: uppercase;
                  letter-spacing: 0.1em;
                  padding: 0.5rem 1rem;
                  border-radius: 20px;
                  display: inline-block;
                  border: 1px solid rgba(129, 140, 248, 0.2);
                  margin-bottom: 2rem;
              }

              h1 {
                  font-size: 3.5rem;
                  font-weight: 800;
                  margin-bottom: 1rem;
                  letter-spacing: -0.02em;
                  line-height: 1;
              }

              h1 span {
                  background: linear-gradient(to bottom right, #fff, #6366f1);
                  -webkit-background-clip: text;
                  -webkit-text-fill-color: transparent;
              }

              .subtitle {
                  color: var(--text-muted);
                  font-size: 1.1rem;
                  margin-bottom: 3rem;
              }

              .status-card {
                  background: rgba(0, 0, 0, 0.2);
                  border: 1px solid var(--glass-border);
                  border-radius: 16px;
                  padding: 2rem;
                  margin-bottom: 3rem;
              }

              .status-indicator {
                  display: flex;
                  justify-content: center;
                  align-items: center;
                  gap: 0.75rem;
                  margin-bottom: 1.5rem;
              }

              .pulse {
                  width: 12px;
                  height: 12px;
                  background: #10B981;
                  border-radius: 50%;
                  box-shadow: 0 0 0 rgba(16, 185, 129, 0.4);
                  animation: pulse-animation 2s infinite;
              }

              @keyframes pulse-animation {
                  0% { box-shadow: 0 0 0 0 rgba(16, 185, 129, 0.7); }
                  70% { box-shadow: 0 0 0 10px rgba(16, 185, 129, 0); }
                  100% { box-shadow: 0 0 0 0 rgba(16, 185, 129, 0); }
              }

              .stats {
                  display: grid;
                  grid-template-columns: repeat(3, 1fr);
                  gap: 1.5rem;
              }

              .stat {
                  display: flex;
                  flex-direction: column;
              }

              .label {
                  font-size: 0.7rem;
                  text-transform: uppercase;
                  color: var(--text-muted);
                  letter-spacing: 0.1em;
                  margin-bottom: 0.25rem;
              }

              .value {
                  font-weight: 600;
                  font-size: 1.1rem;
              }

              footer p {
                  font-size: 0.9rem;
                  color: var(--text-muted);
                  margin-bottom: 2rem;
              }

              .social-links {
                  display: flex;
                  gap: 1rem;
                  justify-content: center;
              }

              .btn-primary, .btn-secondary {
                  padding: 0.75rem 1.5rem;
                  border-radius: 12px;
                  text-decoration: none;
                  font-weight: 600;
                  font-size: 0.875rem;
                  transition: all 0.2s;
              }

              .btn-primary {
                  background: var(--primary);
                  color: white;
              }

              .btn-primary:hover {
                  background: var(--primary-light);
                  transform: translateY(-2px);
              }

              .btn-secondary {
                  background: rgba(255, 255, 255, 0.05);
                  color: white;
                  border: 1px solid var(--glass-border);
              }

              .btn-secondary:hover {
                  background: rgba(255, 255, 255, 0.1);
                  transform: translateY(-2px);
              }
              CSS

              cat << 'DOCKER' > Dockerfile
              FROM nginx:alpine
              COPY index.html /usr/share/nginx/html/index.html
              COPY style.css /usr/share/nginx/html/style.css
              EXPOSE 80
              CMD ["nginx", "-g", "daemon off;"]
              DOCKER

              # Build and Run the container in the cloud!
              sudo docker build -t cloud-site .
              sudo docker run -d -p 80:80 --name cs50-cloud-container cloud-site
              EOF

  tags = {
    Name = "MyDockerHost"
  }
}

# --- Output the Public IP Address ---
# This is how we'll find our server after Terraform builds it!
output "public_ip" {
  description = "The public IP address of the Docker host."
  value       = aws_instance.docker_host.public_ip
}
