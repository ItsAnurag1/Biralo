FROM ubuntu:22.04

# Non-interactive apt
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt-get update && \
    apt-get install -y curl python3 ca-certificates && \
    rm -rf /var/lib/apt/lists/*

# Download and install sshx
# This script detects arch/OS and puts sshx in /usr/local/bin
RUN curl -sSf https://sshx.io/get | sh

# Create dummy web content to keep Render service alive
WORKDIR /app
RUN echo "SSHX is running on Render..." > index.html

# Render needs an open port – we'll use 8080
EXPOSE 8080

# Start a simple HTTP server in background, then start sshx in foreground
# sshx must stay in the foreground so Render treats the service as "up"
CMD ["sh", "-lc", "python3 -m http.server 8080 & sshx serve --once"]
