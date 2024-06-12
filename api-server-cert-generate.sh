#!/bin/bash

CERTS_DIR="my-certs"
KUBELET_CONFIG_DIR="/etc/kubernetes"

# Create certs folder if not exists
sudo mkdir -p "$CERTS_DIR"

# Generate CA key
sudo openssl genrsa -out "$CERTS_DIR/ca.key" 2048

# Generate CA certificate
sudo openssl req -x509 -new -nodes -key "$CERTS_DIR/ca.key" -subj "/CN=kubernetes-ca" -days 365 -out "$CERTS_DIR/ca.crt"

# Generate API Server key pair
sudo openssl genrsa -out "$CERTS_DIR/apiserver.key" 2048

# Generate CSR
sudo openssl req -new -key "$CERTS_DIR/apiserver.key" -subj "/CN=kube-apiserver" -out "$CERTS_DIR/apiserver.csr"

# Generate API Server certificate
sudo openssl x509 -req -in "$CERTS_DIR/apiserver.csr" -CA "$CERTS_DIR/ca.crt" -CAkey "$CERTS_DIR/ca.key" -CAcreateserial -out "$CERTS_DIR/apiserver.crt" -days 365

# Configure API Server
cat <<EOF | sudo tee "$CERTS_DIR/apiserver.conf"
apiVersion: kubelet.config.k8s.io/v1beta1
kind: KubeletConfiguration
clusters:
- name: default
  cluster:
    certificate-authority: "$CERTS_DIR/ca.crt"
    server: https://127.0.0.1:6443
EOF

# Copy the kubelet configuration files to the appropriate directories
sudo cp "$CERTS_DIR/apiserver.conf" "$KUBELET_CONFIG_DIR/"

# Restart the kubelet service to apply the changes
sudo systemctl restart kubelet

echo "API Server certificate generated and stored in $CERTS_DIR."
