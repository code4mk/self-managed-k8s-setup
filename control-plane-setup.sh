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

# Fetch the private IP address of the VM
private_ip=$(hostname -I | awk '{print $1}')

# Specify the port for the API server
api_server_port=6443

# Define the path for the config file
kubeadm_config_file="config/kubeadm-custom-config.yml"
kubeadm_generated_config_file="config/actual-kubeadm-custom-config.yml"

print_green "Generate custom kubeadm config"
# Read the contents of kubeadm_config_file, substitute variables, and write to the generated config file
eval "echo \"$(cat $kubeadm_config_file)\"" > $kubeadm_generated_config_file


# Initialize the Kubernetes control plane
print_green "Initializing the Kubernetes control plane (via: kubeadm init)..."
sudo kubeadm init --config="$kubeadm_generated_config_file" --upload-certs

# Set up kubeconfig for the root user
print_green "Setting up kubeconfig for the root user..."
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

print_green "Kubernetes control plane setup complete."
