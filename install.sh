#!/bin/bash
set -e

# Make APT non-interactive
export DEBIAN_FRONTEND=noninteractive
export NEEDRESTART_MODE=a

# Variables
BASE_URL="https://raw.githubusercontent.com/ismailbohra/test/main"
COMPOSE_FILE="docker-compose.yml"

# Update apt once at the start
sudo apt-get update -y

# Check if Docker is installed
if ! command -v docker >/dev/null 2>&1; then
    echo "Docker not found. Installing..."
    sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common gnupg
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    sudo add-apt-repository -y \
       "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
       $(lsb_release -cs) stable"
    sudo apt-get update -y
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io
fi

# Check if Docker Compose is installed
if ! command -v docker-compose >/dev/null 2>&1; then
    echo "Docker Compose not found. Installing..."
    sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" \
        -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
fi

# Check if Git is installed
if ! command -v git >/dev/null 2>&1; then
    echo "Git not found. Installing..."
    sudo apt-get install -y git
fi

# Check if vi (vim-tiny) is installed
if ! command -v vi >/dev/null 2>&1; then
    echo "vi not found. Installing..."
    sudo apt-get install -y vim-tiny
fi

# Fetch docker-compose.yml
echo "Fetching docker-compose.yml..."
curl -fsSL "$BASE_URL/docker-compose.yml" -o "$COMPOSE_FILE"

# ⭐ Create config directories
mkdir -p config/nginx config/postgres

# ⭐ Fetch nginx configs
for file in portal.conf block-80.conf block-443.conf captive-frontend-8001.conf cp-80.conf cp-443.conf; do
    echo "Fetching nginx/$file..."
    curl -fsSL "$BASE_URL/config/nginx/$file" -o "config/nginx/$file"
done

# ⭐ Fetch postgres configs
for file in postgresql.conf pg_hba.conf; do
    echo "Fetching postgres/$file..."
    curl -fsSL "$BASE_URL/config/postgres/$file" -o "config/postgres/$file"
done

# Start containers
echo "Starting containers..."
sudo docker-compose -f "$COMPOSE_FILE" up -d

echo "Setup completed."
