#!/bin/bash
set -e


DIALOG=whiptail
K8S_VERSION=v1.23.6+k3s1 # from https://github.com/k3s-io/k3s/releases/

K8S_INGRESS_CONF_URL="https://get.stopphish.ru/traefik-config.yaml"



if [ "$EUID" -ne 0 ]
  then
  echo "Must be executed as root"
  exit
fi

if ! ($DIALOG --clear --title  "StopPhish | Installation" --no-button "Cancel" --yesno "Proceed with installation?\n\nStopphish will be installed to the current directory." 10 60 ); then
    exit;
fi

curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION=$K8S_VERSION sh -

if [[ $(k3s kubectl get clusterrolebinding traefik-global-read --ignore-not-found) ]]; then
  echo "Traefik rolebinding already exists, skipping";
else
  echo "Creating traefik rolebinding";
  k3s kubectl create clusterrolebinding --clusterrole=view --serviceaccount=kube-system:traefik traefik-global-read
fi;

if [[ $(k3s kubectl get crd certificates.cert-manager.io --ignore-not-found) ]]; then
  echo "Cert-manager already exists, skipping";
else
  echo "Installing cert-manager";
  k3s kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.8.0/cert-manager.yaml
fi;


curl -s "$K8S_INGRESS_CONF_URL" -o /var/lib/rancher/k3s/server/manifests/traefik-config.yaml
service k3s restart

if [[ $(k3s kubectl get ns stopphish --ignore-not-found) ]]; then
  echo "Stopphish namespace already exists, skipping";
else
  echo "Creating stopphish namespace";
  k3s kubectl create ns stopphish
fi;

k3s kubectl apply -n stopphish -f ./configs/

echo "StopPhish data will be located at: /srv/stopphish";
echo "Downloading StopPhish ... (May take up to several minutes)";
k3s kubectl wait --for=condition=available --timeout=5m deployment -n stopphish api
k3s kubectl wait --for=condition=available --timeout=5m deployment -n stopphish frontend

echo "Starting StopPhish ...";

$DIALOG --title "StopPhish | Congratulations" --msgbox "Installation complete! \n\nYou can now login to\n  $PUBLIC_URL \n  Login: admin@admin.com\n  Password: admin" 20 60

echo -e "\n\n+-------------------------------+\n|     Installation complete!    |\n+-------------------------------+\n"
echo -e "You can now login to:\n  URL :  http://localhost:80 \n  User:  admin@admin.com\n  Pass:  admin\n"

echo -e "* You may now exit the console. *\n"