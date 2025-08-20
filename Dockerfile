FROM n8nio/n8n:latest

# Switch to root user to install packages
USER root

# Install Ngrok menggunakan apk
RUN apk update && apk add --no-cache wget jq && \
    wget -q https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-amd64.tgz && \
    tar -xzf ngrok-v3-stable-linux-amd64.tgz -C /usr/local/bin && \
    rm ngrok-v3-stable-linux-amd64.tgz && \
    chmod +x /usr/local/bin/ngrok

# Copy startup script
COPY start-n8n.sh /start-n8n.sh
RUN chmod +x /start-n8n.sh

# Switch back to node user for security
USER node

# Expose ports
EXPOSE 5678 80

CMD ["/start-n8n.sh"]