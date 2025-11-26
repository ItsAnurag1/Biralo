FROM ubuntu:22.04

# Install dependencies
RUN apt-get update && \
    apt-get install -y \
        curl \
        ca-certificates \
        iproute2 \
        iptables \
        python3 \
        gnupg && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Install Tailscale
RUN curl -fsSL https://tailscale.com/install.sh | sh

# App directory and dummy page
WORKDIR /app
RUN echo "Tailscale + HTTP server is running..." > index.html

# Copy entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# HTTP port
EXPOSE 8080

# Start Tailscale + HTTP server
CMD ["/entrypoint.sh"]
