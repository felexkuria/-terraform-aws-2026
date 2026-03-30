# 🐳 Lab: This is Docker.

OH, THIS IS EXCITING! Welcome to a hands-on exploration of the modern cloud's most fundamental building block. Today, we're not just writing code; we're **orchestrating environments**. We're taking a beautiful, modern web application and packaging it so perfectly that it can run anywhere in the world—from your laptop to the most massive data centers on the planet—with just a single command.

This is the power of **Containerization**.

---

## 🏛️ The Philosophy

Imagine you've built a magnificent house. But you want to move it. In the traditional world, you'd have to take it apart, piece by piece, and hope you can put it back together in the new location. You might forget a nail, or the new soil might be different.

**Docker** is like shrinking that entire house, along with its foundation, its plumbing, and its electricity, into a single, indestructible shipping container. No matter where you ship that container, the house inside remains exactly the same.

---

## 🏁 Getting Started

We're going to dive right in. This lab assumes you have a **Docker-compatible runtime** on your machine. 

### 🍏 For the Mac M1/M2/M3 Users (Apple Silicon)

If you're using a modern Mac and prefer a lightweight, open-source alternative to Docker Desktop, we recommend **Colima**! It's a fantastic way to run containers directly on Apple Silicon.

To get set up with Colima, ensure you have [Homebrew](https://brew.sh/) installed, then run:

```bash
# 1. Install Colima and the Docker CLI
brew install colima docker

# 2. Start the Colima virtual machine
colima start
```

Once started, Colima "wires up" the Docker CLI so it works exactly like we expect!

### 🐳 The Standard Approach

Alternatively, if you're using **Docker Desktop** (available on Windows, Mac, and Linux), ensure the application is open and running.

To check if you're ready to go—regardless of whether you're using Colima or Docker Desktop—open your terminal and run:

```bash
docker --version
```

If you see a version number, you are ready to build!

### Step 1: Examine the Architecture

We've provided you with three essential files:

1.  `index.html`: Our structural blueprint.
2.  `style.css`: Our aesthetic layer (with some beautiful glassmorphism!).
3.  `Dockerfile`: The **recipe** for our container.

Take a moment to look at the `Dockerfile`. Notice how it starts with `FROM nginx:alpine`. This is us saying, "I don't want to build a web server from scratch; I want to stand on the shoulders of giants!"

---

## 🛠️ Step 2: Building the Image

Now, we need to take our "recipe" (the Dockerfile) and turn it into a "cake" (the Image). In your terminal, navigate to this directory and run:

```bash
docker build -t my-beautiful-site .
```

Let's break this down:
- `docker build`: "Hey Docker, build something!"
- `-t my-beautiful-site`: "Tag this image with a friendly name: `my-beautiful-site`."
- `.`: "Look for the `Dockerfile` right here in this current directory."

**Watch the terminal!** You'll see Docker pulling the base image, copying your files, and finalizing the build. This is the assembly line in action!

---

## 🚀 Step 3: Launching the Container

We have the image. Now, let's bring it to life! Run:

```bash
docker run -d -p 8080:80 --name cs50-container my-beautiful-site
```

The flags are crucial:
- `-d`: **Detached mode**. Run this in the background so we can keep using our terminal.
- `-p 8080:80`: **Port Mapping**. Map port `8080` on *your machine* to port `80` *inside the container*. 
- `--name cs50-container`: Give our running instance a professional name.
- `my-beautiful-site`: Use the image we just built!

---

## 🌐 Step 4: The Moment of Truth

Open your favorite web browser and navigate to:

[http://localhost:8080](http://localhost:8080)

**BOOM!** If you see a vibrant, pulsing, glassmorphic landing page, you have officially containerized your first application. This isn't just a website; it's a **portable piece of infrastructure**.

---

## 🧹 Step 5: Clean Up

In the world of infrastructure, we don't leave things running forever if we don't need them. To stop and remove your container:

```bash
docker stop cs50-container
docker rm cs50-container
```

---

## 🎓 Conclusion

You've just taken a massive step toward mastering the modern web. You've gone from raw source code to a standardized, isolated, and scalable container. 

This is just the beginning. Imagine deploying *hundreds* of these. Imagine orchestrating them with **Kubernetes** or **Terraform**. The world is your oyster!

**Happy coding! This is CS50.**
