FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt-get update && \
    apt-get install -y curl python3 ca-certificates && \
    rm -rf /var/lib/apt/lists/*

# Dummy web content so Render sees a web service
WORKDIR /app
RUN echo "SSHX is running on Render..." > index.html

# Render needs an open port
EXPOSE 8080

# Start HTTP server (for Render) + run sshx (prints URL in logs)
CMD ["sh", "-lc", "python3 -m http.server 8080 & curl -sSf https://sshx.io/get | sh -s run"]
