#!/bin/bash

# Par défaut : version 1.12.1
VERSION=${1:-"1.12.1"}

# Détection OS et arch
OS=$(uname | tr '[:upper:]' '[:lower:]')
ARCH=$(uname -m)
if [[ "$ARCH" == "x86_64" ]]; then
  ARCH="amd64"
elif [[ "$ARCH" == "aarch64" || "$ARCH" == "arm64" ]]; then
  ARCH="arm64"
else
  echo "Architecture non supportée: $ARCH"
  exit 1
fi

# URL de téléchargement
URL="https://releases.hashicorp.com/terraform/${VERSION}/terraform_${VERSION}_${OS}_${ARCH}.zip"

echo ">> Téléchargement de Terraform v$VERSION depuis $URL"
curl -LO "$URL"

# Vérifier le téléchargement
if [ ! -f "terraform_${VERSION}_${OS}_${ARCH}.zip" ]; then
  echo "Erreur de téléchargement."
  exit 1
fi

# Décompresser et installer
unzip -o "terraform_${VERSION}_${OS}_${ARCH}.zip"
sudo mv terraform /usr/local/bin/
rm "terraform_${VERSION}_${OS}_${ARCH}.zip"

# Vérification
echo "✅ Terraform installé avec succès :"
terraform version



# Install vault

wget -O - https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(grep -oP '(?<=UBUNTU_CODENAME=).*' /etc/os-release || lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install vault


export VAULT_ADDR='http://127.0.0.1:8200'
export VAULT_TOKEN=$(vault print token)
export TF_VAR_vault_token=$(vault print token)


