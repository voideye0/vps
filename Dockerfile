# Define an argument NGROK_TOKEN and set it as an environment variable
ARG NGROK_TOKEN

# Set the base image to the latest version of Ubuntu
FROM ubuntu:latest

# Update the package lists, upgrade installed packages to the latest version, and install locales
RUN apt update -y > /dev/null 2>&1 && \
    apt upgrade -y > /dev/null 2>&1 && \
    apt install locales ssh wget unzip -y > /dev/null 2>&1 && \
    localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8 && \
    echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config && \
    echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config && \
    echo root:odiyaan|chpasswd && \
    service ssh start && \
    wget -O ngrok.zip https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-amd64.zip > /dev/null 2>&1 && \
    unzip ngrok.zip && \
    mkdir /run/sshd && \
    chmod 755 /odiyaan.sh

# Define an environment variable for the default locale
ENV LANG en_US.utf8

# Define an environment variable for the ngrok token
ENV NGROK_TOKEN=${NGROK_TOKEN}

# Expose necessary ports
EXPOSE 80 8888 8080 443 5130 5131 5132 5133 5134 5135 3306

# Create entrypoint script 
RUN echo '#!/bin/bash' >> /entrypoint.sh && \
    echo 'export NGROK_TOKEN="your_actual_ngrok_authtoken"' >> /entrypoint.sh && \
    echo './ngrok config add-authtoken ${NGROK_TOKEN} &&' >> /entrypoint.sh && \
    echo './ngrok tcp --region in 22 &>/dev/null &' >> /entrypoint.sh && \
    echo '/usr/sbin/sshd -D' >> /entrypoint.sh && \
    chmod +x /entrypoint.sh

# Set entrypoint (No need for CMD)
ENTRYPOINT ["/entrypoint.sh"]
