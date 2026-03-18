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
  echo "<!DOCTYPE html>
  <html lang="en">
  <head>
      <meta charset="UTF-8">
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
      <title>Priority Tasks</title>
      <style>
          :root {
              --bg: #0f172a;
              --card-bg: rgba(30, 41, 59, 0.7);
              --accent: #6366f1;
              --accent-hover: #818cf8;
              --text: #f1f5f9;
              --text-muted: #94a3b8;
              --border: rgba(255, 255, 255, 0.1);
          }

          * {
              margin: 0;
              padding: 0;
              box-sizing: border-box;
          }

          body {
              background-color: var(--bg);
              color: var(--text);
              font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
              display: flex;
              justify-content: center;
              align-items: center;
              min-height: 100vh;
              padding: 20px;
          }

          .container {
              width: 100%;
              max-width: 440px;
              background: var(--card-bg);
              backdrop-filter: blur(20px);
              border-radius: 24px;
              padding: 40px;
              box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.5);
              border: 1px solid var(--border);
          }

          h1 {
              font-size: 32px;
              font-weight: 800;
              margin-bottom: 8px;
              text-align: center;
              background: linear-gradient(to right, #818cf8, #c084fc);
              -webkit-background-clip: text;
              -webkit-text-fill-color: transparent;
          }

          p.subtitle {
              color: var(--text-muted);
              text-align: center;
              font-size: 14px;
              margin-bottom: 32px;
          }

          .input-group {
              position: relative;
              margin-bottom: 32px;
          }

          input {
              width: 100%;
              background: rgba(15, 23, 42, 0.6);
            border: 1px solid var(--border);
              border-radius: 16px;
              padding: 16px 20px;
              color: white;
              font-size: 16px;
              outline: none;
              transition: all 0.3s ease;
          }

          input:focus {
              border-color: var(--accent);
              box-shadow: 0 0 0 4px rgba(99, 102, 241, 0.2);
          }

          .add-btn {
              position: absolute;
              right: 8px;
              top: 8px;
              background: var(--accent);
              color: white;
              border: none;
              border-radius: 10px;
              padding: 8px 16px;
              font-weight: 600;
              cursor: pointer;
              transition: background 0.2s ease;
          }

          .add-btn:hover {
              background: var(--accent-hover);
          }

          .todo-list {
              list-style: none;
              display: flex;
              flex-direction: column;
              gap: 12px;
          }

          .todo-item {
              background: rgba(51, 65, 85, 0.3);
              padding: 16px;
              border-radius: 12px;
              display: flex;
              align-items: center;
              justify-content: space-between;
              border: 1px solid transparent;
              transition: all 0.2s ease;
          }

          .todo-item:hover {
              border-color: rgba(99, 102, 241, 0.3);
              background: rgba(51, 65, 85, 0.5);
          }

          .todo-content {
              display: flex;
              align-items: center;
              gap: 12px;
          }

          .checkbox {
              width: 20px;
              height: 20px;
              border: 2px solid var(--text-muted);
              border-radius: 6px;
              cursor: pointer;
              display: flex;
              align-items: center;
              justify-content: center;
          }

          .todo-item.completed .checkbox {
              background: var(--accent);
              border-color: var(--accent);
          }

          .todo-item.completed span {
              text-decoration: line-through;
              color: var(--text-muted);
          }

          .delete-btn {
              color: var(--text-muted);
              cursor: pointer;
          }

          .delete-btn:hover {
              color: #ef4444;
          }

          footer {
              margin-top: 32px;
              padding-top: 24px;
              border-top: 1px solid var(--border);
              display: flex;
              justify-content: space-between;
              font-size: 12px;
              color: var(--text-muted);
          }
      </style>
  </head>
  <body>
      <div class="container">
          <h1>Priority</h1>
          <p class="subtitle">Personal Task Management</p>
          
          <div class="input-group">
              <input type="text" placeholder="Add a task...">
              <button class="add-btn">Add</button>
          </div>

          <ul class="todo-list">
              <li class="todo-item">
                  <div class="todo-content">
                      <div class="checkbox"></div>
                      <span>Design System Review</span>
                  </div>
                  <div class="delete-btn">✕</div>
              </li>
              <li class="todo-item completed">
                  <div class="todo-content">
                      <div class="checkbox">✓</div>
                      <span>Setup AWS Infrastructure</span>
                  </div>
                  <div class="delete-btn">✕</div>
              </li>
              <li class="todo-item">
                  <div class="todo-content">
                      <div class="checkbox"></div>
                      <span>Client Presentation</span>
                  </div>
                  <div class="delete-btn">✕</div>
              </li>
          </ul>

          <footer>
              <span>2 tasks left</span>
              <span>Clear Completed</span>
          </footer>
      </div>
  </body>
  </html>" >index.html

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