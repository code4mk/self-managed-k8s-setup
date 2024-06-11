#!/bin/bash

# Exit on any error
set -e

# Run containerd installation
echo "Running containerd installation..."
./common/containerd-install.sh

# Run Kubernetes installation
echo "Running Kubernetes installation..."
./common/k8s-install.sh

# Read join-token.txt and execute the command with sudo
if [ ! -f "join-token.txt" ]; then
    echo "Error: join-token.txt not found."
    exit 1
fi

join_command=$(cat join-token.txt)
echo "Joining the worker node to the Kubernetes cluster..."
sudo $join_command

echo "Worker node joined to the Kubernetes cluster."


