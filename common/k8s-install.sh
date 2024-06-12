#!/bin/bash

# Function to print messages in green
print_green() {
    echo -e "\e[42m$1\e[0m"
}

# Update package index
print_green "Updating package index..."
sudo apt-get update

# Install necessary packages
print_green "Installing required packages..."
sudo apt-get install -y apt-transport-https ca-certificates curl gpg

# Ensure /etc/apt/keyrings directory exists
if [ ! -d "/etc/apt/keyrings" ]; then
    print_green "Creating /etc/apt/keyrings directory..."
    sudo mkdir -p -m 755 /etc/apt/keyrings
else
    print_green "/etc/apt/keyrings directory good."
fi

# Add Kubernetes apt repository key
print_green "Adding Kubernetes apt repository key..."
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.30/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

# Add Kubernetes apt repository
print_green "Adding Kubernetes apt repository..."
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.30/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list

# Update package index again
print_green "Updating package index again..."
sudo apt-get update

# Install Kubernetes components
print_green "Installing Kubernetes components..."
sudo apt-get install -y kubelet kubeadm kubectl

# Mark Kubernetes components to hold
print_green "Holding Kubernetes components..."
sudo apt-mark hold kubelet kubeadm kubectl

# Enable and start kubelet service
print_green "Enabling and starting kubelet service..."
sudo systemctl enable --now kubelet

# Check kubeadm version
print_green "Checking kubeadm version..."
kubeadm version

# Check kubelet service status
print_green "Checking kubelet service status..."
sudo systemctl status kubelet
