#!/bin/bash

# Exit on any error
set -e

# Function to print messages in green
print_green() {
    echo -e "\e[42m$1\e[0m"
}

# Run containerd installation
print_green "Running containerd installation..."
./common/containerd-install.sh

# Run Kubernetes installation
print_green "Running Kubernetes installation..."
./common/k8s-install.sh


# Fetch public IP address of the VM
public_ip=$(curl -s http://checkip.amazonaws.com)

# Specify the port for the API server
api_server_port=6443

# Initialize the Kubernetes control plane
print_green "Initializing the Kubernetes control plane..."
#sudo kubeadm init --pod-network-cidr=10.244.0.0/16 --apiserver-advertise-address=$(hostname -I | awk '{print $1}') --upload-certs --control-plane-endpoint=193.10.1.5
sudo kubeadm init \
 --pod-network-cidr=10.244.0.0/16 \
 --apiserver-advertise-address=${public_ip} \
 --control-plane-endpoint=${public_ip}:${api_server_port} \
 --upload-certs


# Set up kubeconfig for the root user
print_green "Setting up kubeconfig for the root user..."
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Print and store the join command for worker nodes
print_green "Printing the join command for worker nodes..."
JOIN_COMMAND=$(sudo kubeadm token create --print-join-command)
echo -e "\e[42m$JOIN_COMMAND\e[0m"

print_green "Kubernetes control plane setup complete. The join command has been saved to join-token.txt."
