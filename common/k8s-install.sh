#!/bin/bash

# Update package index
echo "Updating package index..."
sudo apt-get update

# Install necessary packages
echo "Installing required packages..."
sudo apt-get install -y apt-transport-https ca-certificates curl gpg

# Ensure /etc/apt/keyrings directory exists
if [ ! -d "/etc/apt/keyrings" ]; then
    echo "Creating /etc/apt/keyrings directory..."
    sudo mkdir -p -m 755 /etc/apt/keyrings
else
    echo "/etc/apt/keyrings directory already exists."
fi

# Add Kubernetes apt repository key
echo "Adding Kubernetes apt repository key..."
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.30/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

# Add Kubernetes apt repository
echo "Adding Kubernetes apt repository..."
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.30/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list

# Update package index again
echo "Updating package index again..."
sudo apt-get update

# Install Kubernetes components
echo "Installing Kubernetes components..."
sudo apt-get install -y kubelet kubeadm kubectl

# Mark Kubernetes components to hold
echo "Holding Kubernetes components..."
sudo apt-mark hold kubelet kubeadm kubectl

# Enable and start kubelet service
echo "Enabling and starting kubelet service..."
sudo systemctl enable --now kubelet

# Check kubeadm version
echo "Checking kubeadm version..."
kubeadm version

# Check kubelet service status
echo "Checking kubelet service status..."
sudo systemctl status kubelet
