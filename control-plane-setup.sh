#!/bin/bash

# Exit on any error
set -e

# Run containerd installation
echo "Running containerd installation..."
./common/containerd-install.sh

# Run Kubernetes installation
echo "Running Kubernetes installation..."
./common/k8s-install.sh

# Initialize the Kubernetes control plane
echo "Initializing the Kubernetes control plane..."
sudo kubeadm init --pod-network-cidr=10.244.0.0/16 --apiserver-advertise-address=$(hostname -I | awk '{print $1}')

# Set up kubeconfig for the root user
echo "Setting up kubeconfig for the root user..."
sudo mkdir -p /root/.kube
sudo cp -i /etc/kubernetes/admin.conf /root/.kube/config
sudo chown root:root /root/.kube/config

# Set up kubeconfig for the current (non-root) user, if applicable
if [ "$SUDO_USER" ]; then
    echo "Setting up kubeconfig for the current user ($SUDO_USER)..."
    mkdir -p /home/$SUDO_USER/.kube
    sudo cp -i /etc/kubernetes/admin.conf /home/$SUDO_USER/.kube/config
    sudo chown $SUDO_USER:$SUDO_USER /home/$SUDO_USER/.kube/config
fi

# Apply a pod network add-on (using Flannel in this example)
echo "Applying the Flannel network add-on..."
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml

# Print and store the join command for worker nodes
echo "Printing the join command for worker nodes..."
sudo kubeadm token create --print-join-command | tee join-token.txt

# Check the status of the control plane components
echo "Checking the status of the control plane components..."
kubectl get nodes
kubectl get pods --all-namespaces

echo "Kubernetes control plane setup complete. The join command has been saved to join-token.txt."
