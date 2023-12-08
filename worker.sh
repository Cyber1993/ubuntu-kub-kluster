#! /bin/bash



sudo swapoff -a
sudo sed -i '/ swap / s/^/#/' /etc/fstab
sudo hostnamectl set-hostname "worker-node1"
exec bash
+++++++++++++++++++++++++++++
echo "network:
  ethernets:
    enp0s3:
      addresses:
      - 10.7.135.15/16
      gateway4: 10.7.0.101
      nameservers:
        addresses:
        - 10.7.0.101
  version: 2" > /etc/netplan/00-installer-config.yaml 


network:
  ethernets:
    enp0s3:
      addresses:
      - 10.7.135.15/16
      gateway4: 10.7.0.101
      nameservers:
        addresses:
        - 10.7.0.101
  version: 2

  netplan apply
+++++++++++++++++++++++++++


echo "10.7.12.200 master-node
10.7.12.201 worker-node1" >> /etc/hosts

sudo nano /etc/hosts

10.7.12.200 master-node
10.7.12.201 worker-node1

_______________________________________________


cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

# sysctl params required by setup, params persist across reboots
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

# Apply sysctl params without reboot
sudo sysctl --system

sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl
sudo mkdir /etc/apt/keyrings
curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-archive-keyring.gpg
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt install -y kubelet=1.26.5-00 kubeadm=1.26.5-00 kubectl=1.26.5-00

sudo apt install docker.io
sudo mkdir /etc/containerd
sudo sh -c "containerd config default > /etc/containerd/config.toml"
sudo sed -i 's/ SystemdCgroup = false/ SystemdCgroup = true/' /etc/containerd/config.toml
sudo systemctl restart containerd.service
sudo systemctl restart kubelet.service
sudo systemctl enable kubelet.service


^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

kubeadm join 10.7.12.200:6443 --token ebjgdn.7i07qlevqvh2seyt \
	--discovery-token-ca-cert-hash sha256:843b033e26d67fac40a61ab11ce571cd653f2445cb91385a7e39cd968ecffdc0 


^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
