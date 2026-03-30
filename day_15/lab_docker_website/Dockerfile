# --- The Blueprint: Dockerfile ---
# We start with a base image. Nginx is a high-performance web server.
# Alpine is a super-small, lightweight Linux distribution.
FROM nginx:alpine

# Metadata: Let's tag this image so we know who built it!
LABEL maintainer="CS50 Student <student@cs50.harvard.edu>"

# --- The Assembly: Copying our Files ---
# We copy our local index.html and style.css into the container's 
# default directory for serving static content.
COPY index.html /usr/share/nginx/html/index.html
COPY style.css /usr/share/nginx/html/style.css

# --- The Logistics: Opening Ports ---
# Nginx traditionally runs on port 80. We tell Docker that our
# container intends to listen on this port.
EXPOSE 80

# --- The Startup: Launching the Server ---
# This command tells Docker exactly what to execute when the container starts.
# Nginx will run in the foreground so the container stays alive.
CMD ["nginx", "-g", "daemon off;"]
