#!/bin/bash

# Function to print messages in green
print_green() {
    echo -e "\e[42m$1\e[0m"
}

# Exit on any error
set -e

# Prompt user for the full join command
read -p "Enter the full join command to join the worker node to the Kubernetes cluster: " join_command

# Check if the join command is empty
if [ -z "$join_command" ]; then
    echo -e "\e[41mError: Join command cannot be empty.\e[0m"
    exit 1
fi

# Join the worker node to the Kubernetes cluster using the provided join command
print_green "Joining the worker node to the Kubernetes cluster..."
sudo $join_command

print_green "Worker node joined to the Kubernetes cluster."
