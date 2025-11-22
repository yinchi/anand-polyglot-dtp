#!/usr/bin/env bash

set -euo pipefail

APT_FLAGS="-yqo APT::Get::HideAutoRemove=1"

# Check for Docker Compose
if ! docker compose version &> /dev/null
then
    echo "Docker could not be found.  Choose option:"
    echo "1) Install Docker CLI (not recommend if using Docker Desktop)"
    echo "2) Exit setup and install Docker manually"
    
    read -p "Enter choice [1-2]: " choice
    case $choice in
        1)
            echo "🔨  Installing Docker CLI..."
            
            echo "🗑️  Removing any old Docker versions..."
            sudo apt remove $(dpkg --get-selections docker.io docker-compose docker-compose-v2 docker-doc podman-docker containerd runc | cut -f1) || true

            echo "🔨  Installing Docker dependencies..."
            sudo apt-get $APT_FLAGS update
            sudo apt-get install $APT_FLAGS ca-certificates curl

            echo "📝  Adding Docker repository..."
            sudo install -m 0755 -d /etc/apt/keyrings
            sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
            sudo chmod a+r /etc/apt/keyrings/docker.asc

            echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    
            echo "🔨  Installing Docker..."
            sudo apt-get $APT_FLAGS update
            sudo apt-get install $APT_FLAGS docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
            echo "✅  Docker installation completed."
            ;;
        2)
            echo "Exiting setup. Please install Docker and re-run the setup."
            exit 1
            ;;
        *)
            echo "Invalid choice. Exiting setup."
            exit 1
            ;;
    esac
else
    echo "✅  Docker is already installed."
    docker --version
    docker compose version
    echo ""
fi

echo "🔨  Installing additional packages..."
sudo apt-get $APT_FLAGS install \
    make \
    python3-venv python3-click \
    wget curl \
    pgcli \
    mosquitto-clients

echo "✅  Installed required packages."

echo "🔨  Setting up Python virtual environment..."
make venv
echo "✅  Python virtual environment is set up."
echo ""

echo "🔨  Installing LazyDocker..."
curl https://raw.githubusercontent.com/jesseduffield/lazydocker/master/scripts/install_update_linux.sh | bash
echo "✅  LazyDocker installation completed."
echo ""

echo "🔨  Configuring ~/.bashrc to include ~/.local/bin in PATH..."
if ! echo $PATH | tr ':' '\n' | grep -qx "$HOME/.local/bin"; then
    cat << 'EOF' >> "$HOME/.bashrc"

# Add ~/.local/bin to PATH if not already in PATH
if ! echo $PATH | tr ':' '\n' | grep -qx "$HOME/.local/bin"; then
    export PATH="$HOME/.local/bin:$PATH"
fi
EOF
    export PATH="$HOME/.local/bin:$PATH"
    echo "✅  Added ~/.local/bin to PATH in .bashrc."
else
    echo "✅  ~/.local/bin is already in PATH."
fi
echo ""

echo "🔨  Adding current user to 'docker' group..."
if ! getent group docker > /dev/null; then
    echo "Creating the 'docker' group..."
    sudo groupadd docker
    echo "✅  'docker' group created."
fi
sudo usermod -aG docker $USER
echo "✅  Added user '$USER' to 'docker' group."
echo ""

echo "🔨  Installing yq YAML processor..."
sudo wget -q https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 \
    -O /usr/local/bin/yq \
    && sudo chmod +x /usr/local/bin/yq
echo "✅  yq installation completed."
echo ""

echo "✅  Setup completed successfully!  Please log out and log back in for changes to take effect."
