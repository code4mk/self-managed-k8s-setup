#!/bin/bash

CERTS_DIR="/etc/kubernetes/my-certs"
KUBELET_CONFIG_DIR="/etc/kubernetes"

# Create certs folder if not exists
if ! sudo mkdir -p "$CERTS_DIR"; then
    echo "Error: Failed to create directory $CERTS_DIR"
    exit 1
fi

# Generate CA key
if ! sudo openssl genrsa -out "$CERTS_DIR/ca.key" 2048; then
    echo "Error: Failed to generate CA key"
    exit 1
fi

# Generate CA certificate
if ! sudo openssl req -x509 -new -nodes -key "$CERTS_DIR/ca.key" -subj "/CN=kubernetes-ca" -days 365 -out "$CERTS_DIR/ca.crt"; then
    echo "Error: Failed to generate CA certificate"
    exit 1
fi

# Generate API Server key pair
if ! sudo openssl genrsa -out "$CERTS_DIR/apiserver.key" 2048; then
    echo "Error: Failed to generate API Server key pair"
    exit 1
fi

# Generate CSR
if ! sudo openssl req -new -key "$CERTS_DIR/apiserver.key" -subj "/CN=kube-apiserver" -out "$CERTS_DIR/apiserver.csr"; then
    echo "Error: Failed to generate CSR"
    exit 1
fi

# Generate API Server certificate
if ! sudo openssl x509 -req -in "$CERTS_DIR/apiserver.csr" -CA "$CERTS_DIR/ca.crt" -CAkey "$CERTS_DIR/ca.key" -CAcreateserial -out "$CERTS_DIR/apiserver.crt" -days 365; then
    echo "Error: Failed to generate API Server certificate"
    exit 1
fi

# Configure API Server
if ! sudo tee "$CERTS_DIR/apiserver.conf" > /dev/null <<EOF
apiVersion: kubelet.config.k8s.io/v1beta1
kind: KubeletConfiguration
clusters:
- name: default
  cluster:
    certificate-authority: "$CERTS_DIR/ca.crt"
    server: https://127.0.0.1:6443
EOF
then
    echo "Error: Failed to configure API Server"
    exit 1
fi

# Copy the kubelet configuration files to the appropriate directories
if ! sudo cp "$CERTS_DIR/apiserver.conf" "$KUBELET_CONFIG_DIR/"; then
    echo "Error: Failed to copy kubelet configuration files"
    exit 1
fi

# Restart the kubelet service to apply the changes
if ! sudo systemctl restart kubelet; then
    echo "Error: Failed to restart kubelet service"
    exit 1
fi

echo "API Server certificate generated and stored in $CERTS_DIR."

# Optionally, clean-up CSR and CA serial files
# sudo rm "$CERTS_DIR/apiserver.csr" "$CERTS_DIR/ca.srl"
