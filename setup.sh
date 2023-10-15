#! /bin/sh
date

SCRIPT_DIR=$(cd $(dirname $0); pwd)

## update ubuntu
sed -i "s/#\$nrconf{kernelhints} = -1;/\$nrconf{kernelhints} = -1;/g" /etc/needrestart/needrestart.conf
sed -i "/#\$nrconf{restart} = 'i';/s/.*/\$nrconf{restart} = 'a';/" /etc/needrestart/needrestart.conf
apt update
apt upgrade -y

## allow root login & set ssh alive interval
new_sshd_config="$SCRIPT_DIR/sshd_config"
current_sshd_config="/etc/ssh/sshd_config"
backup_sshd_config="$current_sshd_config.backup"
cp "$current_sshd_config" "$backup_sshd_config"
cp "$new_sshd_config" "$current_sshd_config"
mv /root/.ssh/authorized_keys /root/.ssh/authorized_keys_bak
cp -f /home/ubuntu/.ssh/authorized_keys /root/.ssh/authorized_keys
service sshd reload

## minikube
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
install minikube-linux-amd64 /usr/local/bin/minikube
rm -rf minikube-linux-amd64

## conntrack
apt-get install -y conntrack

## crictl
VERSION="v1.28.0"
wget https://github.com/kubernetes-sigs/cri-tools/releases/download/$VERSION/crictl-$VERSION-linux-amd64.tar.gz
tar zxvf crictl-$VERSION-linux-amd64.tar.gz -C /usr/local/bin
rm -f crictl-$VERSION-linux-amd64.tar.gz

## kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
mv ./kubectl /usr/local/bin/kubectl

## docker
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh
rm -f get-docker.sh

## cri-dockerd
wget https://github.com/Mirantis/cri-dockerd/releases/download/v0.3.4/cri-dockerd_0.3.4.3-0.ubuntu-jammy_amd64.deb
dpkg -i cri-dockerd_0.3.4.3-0.ubuntu-jammy_amd64.deb
rm -rf cri-dockerd_0.3.4.3-0.ubuntu-jammy_amd64.deb

## containernetworkingplugins
CNI_PLUGIN_VERSION="v1.3.0"
CNI_PLUGIN_TAR="cni-plugins-linux-amd64-$CNI_PLUGIN_VERSION.tgz"
CNI_PLUGIN_INSTALL_DIR="/opt/cni/bin"
curl -LO "https://github.com/containernetworking/plugins/releases/download/$CNI_PLUGIN_VERSION/$CNI_PLUGIN_TAR"
mkdir -p "$CNI_PLUGIN_INSTALL_DIR"
tar -xf "$CNI_PLUGIN_TAR" -C "$CNI_PLUGIN_INSTALL_DIR"
rm "$CNI_PLUGIN_TAR"

## ubuntu desktop
sed -i "s/#\$nrconf{kernelhints} = -1;/\$nrconf{kernelhints} = -1;/g" /etc/needrestart/needrestart.conf
sed -i 's/#$nrconf{restart} = '"'"'i'"'"';/$nrconf{restart} = '"'"'a'"'"';/g' /etc/needrestart/needrestart.conf
apt-get install -y ubuntu-desktop

## xrdp
apt-get install -y xrdp
systemctl enable xrdp

echo ---------------------------------------------------
echo Run the command below to complete the installation.
echo ## add rdp user
echo adduser [username]
echo gpasswd -a [username] sudo
echo reboot

echo ## minikube start
echo minikube start --vm-driver=none
echo minikube addons enable ingress
echo ---------------------------------------------------
echo done.
date
