#!/bin/bash

# Exit on any error
set -e

# Function to print messages in green
print_green() {
    echo -e "\e[32m$1\e[0m"
}

# Prompt the user for the public IP address
read -p "Enter the public IP address (or cname): " public_ip
# Check if public_ip is empty
if [[ -z "$public_ip" ]]; then
    echo "Error: Public IP address cannot be empty."
    exit 1
fi

# Prompt the user for the pod network CIDR
read -p "Enter the pod network CIDR (e.g., 10.244.0.0/16): " pod_network_cidr
# Check if pod_network_cidr is empty
if [[ -z "$pod_network_cidr" ]]; then
    echo "Error: Pod network CIDR cannot be empty."
    exit 1
fi

# Run containerd installation
print_green "Running containerd installation..."
#./common/containerd-install.sh

# Run Kubernetes installation
print_green "Running Kubernetes installation..."
#./common/k8s-install.sh

# Fetch the private IP address of the VM
private_ip=$(hostname -I | awk '{print $1}')

# Specify the port for the API server
api_server_port=6443

# Create a temporary configuration file with the actual values
config_file="config/kubeadm-custom-config.yml"

# Update the configuration file with actual values
sed -i "s/\$public_ip/$public_ip/g" $config_file
sed -i "s/\$api_server_port/$api_server_port/g" $config_file
sed -i "s/\$pod_network_cidr/$pod_network_cidr/g" $config_file
sed -i "s/\$private_ip/$private_ip/g" $config_file

# Initialize the Kubernetes control plane
print_green "Initializing the Kubernetes control plane (via: kubeadm init)..."
sudo kubeadm init --config="$config_file" --upload-certs

# Set up kubeconfig for the root user
print_green "Setting up kubeconfig for the root user..."
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

print_green "Kubernetes control plane setup complete."
