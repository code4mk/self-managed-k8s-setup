#!/bin/bash

# Function to print messages in green
print_green() {
    echo -e "\e[42m$1\e[0m"
}

# Update package lists
print_green "Updating package lists..."
sudo apt-get update

# Install packages for HTTPS support
print_green "Installing packages for HTTPS support..."
sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common

# Disable swap
print_green "Disabling swap..."
sudo swapoff -a

# Load necessary kernel modules
print_green "Loading necessary kernel modules..."
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

# Set up sysctl parameters
print_green "Setting up sysctl parameters..."
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

# Apply sysctl parameters
print_green "Applying sysctl parameters..."
sudo sysctl --system

# Verify kernel modules are loaded
print_green "Verifying kernel modules are loaded..."
lsmod | grep br_netfilter
lsmod | grep overlay

# Verify sysctl parameters
print_green "Verifying sysctl parameters..."
sysctl net.bridge.bridge-nf-call-iptables \
      net.bridge.bridge-nf-call-ip6tables \
      net.ipv4.ip_forward

# Install containerd
print_green "Installing containerd..."
sudo apt-get install -y containerd

# Check if the containerd configuration directory exists, then create if it doesn't
if [ ! -d /etc/containerd ]; then
    print_green "Creating containerd configuration directory..."
    sudo mkdir -p /etc/containerd
fi

# Generate default containerd configuration
print_green "Generating default containerd configuration..."
containerd config default | sudo tee /etc/containerd/config.toml

# Update containerd configuration to use systemd cgroup driver
print_green "Updating containerd configuration to use systemd cgroup driver..."
sudo sed -i 's/^SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml
# Restart containerd service
print_green "Restarting containerd service..."
sudo systemctl restart containerd

# Check containerd service status
print_green "Checking containerd service status..."
sudo systemctl status containerd
