# Run containerd installation
print_green "Running containerd installation..."
./common/containerd-install.sh

# Run Kubernetes installation
print_green "Running Kubernetes installation..."
./common/k8s-install.sh