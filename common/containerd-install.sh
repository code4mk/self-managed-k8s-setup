#!/bin/bash

# Disable swap
echo -e "\e[42mDisabling swap...\e[0m"
sudo swapoff -a

# Load necessary kernel modules
echo -e "\e[42mLoading necessary kernel modules...\e[0m"
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

# Set up sysctl parameters
echo -e "\e[42mSetting up sysctl parameters...\e[0m"
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

# Apply sysctl parameters
echo -e "\e[42mApplying sysctl parameters...\e[0m"
sudo sysctl --system

# Verify kernel modules are loaded
echo -e "\e[42mVerifying kernel modules are loaded...\e[0m"
lsmod | grep br_netfilter
lsmod | grep overlay

# Verify sysctl parameters
echo -e "\e[42mVerifying sysctl parameters...\e[0m"
sysctl net.bridge.bridge-nf-call-iptables net.bridge.bridge-nf-call-ip6tables net.ipv4.ip_forward

# Update package index
echo -e "\e[42mUpdating package index...\e[0m"
sudo apt-get update

# Install containerd
echo -e "\e[42mInstalling containerd...\e[0m"
sudo apt-get -y install containerd

# Check if the containerd configuration directory exists, then create if it doesn't
if [ ! -d /etc/containerd ]; then
    echo -e "\e[42mCreating containerd configuration directory...\e[0m"
    sudo mkdir -p /etc/containerd
fi

# Generate default containerd configuration
echo -e "\e[42mGenerating default containerd configuration...\e[0m"
sudo containerd config default | sudo tee /etc/containerd/config.toml

# Update containerd configuration to use systemd cgroup driver
echo -e "\e[42mUpdating containerd configuration to use systemd cgroup driver...\e[0m"
sudo sed -i '/^\[plugins\."io\.containerd\.grpc\.v1\.cri"\.containerd\.runtimes\.runc\.options\]$/,/^\[/ s/SystemdCgroup = false/SystemdCgroup = true/g' /etc/containerd/config.toml

# Restart containerd service
echo -e "\e[42mRestarting containerd service...\e[0m"
sudo systemctl restart containerd

# Check containerd service status
echo -e "\e[42mChecking containerd service status...\e[0m"
sudo systemctl status containerd
