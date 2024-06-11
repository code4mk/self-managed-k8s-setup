#!/bin/bash

# Disable swap
echo "Disabling swap..."
sudo swapoff -a

# Load necessary kernel modules
echo "Loading necessary kernel modules..."
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

# Set up sysctl parameters
echo "Setting up sysctl parameters..."
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

# Apply sysctl parameters
echo "Applying sysctl parameters..."
sudo sysctl --system

# Verify kernel modules are loaded
echo "Verifying kernel modules are loaded..."
lsmod | grep br_netfilter
lsmod | grep overlay

# Verify sysctl parameters
echo "Verifying sysctl parameters..."
sysctl net.bridge.bridge-nf-call-iptables net.bridge.bridge-nf-call-ip6tables net.ipv4.ip_forward

# Update package index
echo "Updating package index..."
sudo apt-get update

# Install containerd
echo "Installing containerd..."
sudo apt-get -y install containerd

# Generate default containerd configuration
echo "Generating default containerd configuration..."
sudo containerd config default | sudo tee /etc/containerd/config.toml

# Update containerd configuration to use systemd cgroup driver
echo "Updating containerd configuration to use systemd cgroup driver..."
sudo sed -i '/^\[plugins\."io\.containerd\.grpc\.v1\.cri"\.containerd\.runtimes\.runc\.options\]$/,/^\[/ s/SystemdCgroup = false/SystemdCgroup = true/g' /etc/containerd/config.toml

# Restart containerd service
echo "Restarting containerd service..."
sudo systemctl restart containerd

# Check containerd service status
echo "Checking containerd service status..."
sudo systemctl status containerd
