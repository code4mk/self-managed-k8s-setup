# self-managed-k8s-setup (WIP)

# clone project -  (control plane and worker node)

```bash
git clone https://github.com/code4mk/self-managed-k8s-setup
```
then change dir `self-managed-k8s-setup`

```bash
cd self-managed-k8s-setup
```

# control plane

1. install k8s (containerd and k8s)

```bash
./k8s-setup.sh
```

2.  then check kubelet status

```bash
./kubelet-status.sh
```

if status is good go to next step (3) if faces error again run install k8s step (1)

3. control-plane setup

```bash
./control-plane-setup.sh
```

4. cni setup

before cni setup need to setup your worker node and worker node join with control plane

* this script setup flannel cni

```bash
./contorl-plane-cni-setup
```

```bash
kubectl get nodes
kubectl get pods -A -o wide
kubectl get svc -A -o wide
```

# Worker node setup

1. install k8s (containerd and k8s)

```bash
./k8s-setup.sh
```

2.  then check kubelet status

```bash
./kubelet-status.sh
```

if status is good go to next step (3) if faces error again run install k8s step (1)

3. join with control plane

you can manually join 

```bash
sudo your_token
```

or 

```bash
./worker-node-setup.sh
```


# connect with  lens

```bash
cd ~
cat .kube/config
```

then copy the cat output and that will submit with lens ( join with kube config)