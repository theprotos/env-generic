#!/usr/bin/env bash

##################### VARIABLES #####################
#tfURL="https://releases.hashicorp.com/terraform/0.12.11/terraform_0.12.11_linux_amd64.zip"
#tflint="https://github.com/terraform-linters/tflint/releases/latest/download/tflint_linux_amd64.zip"
tfdocs="https://github.com/segmentio/terraform-docs/releases/latest/download/terraform-docs-v0.6.0-linux-amd64"
awsvault="https://github.com/99designs/aws-vault/releases/latest/download/aws-vault-linux-amd64"
#direnv="https://github.com/direnv/direnv/releases/latest/download/direnv.linux-amd64"
#vault="https://releases.hashicorp.com/vault/1.1.5/vault_1.1.5_linux_amd64.zip"
#helm="https://get.helm.sh/helm-v3.0.0-linux-amd64.tar.gz"
#minikube="https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64"
#####################################################

printf "$(date +%T) ========[ YUM: Install common packages ]========"
curl -sL https://raw.githubusercontent.com/theprotos/cookbooks-generic/development/scripts/linux.sh | sudo bash -s apply linux-vagrant.json,linux-k8s.json development
curl -sL https://raw.githubusercontent.com/theprotos/cookbooks-generic/development/scripts/linux.sh | sudo bash -s apply linux-vagrant.json,linux-k8s.json development

pip3 install -q pre-commit

function bin_install {
    printf "    ========[ Install $1 ]========"
    curl -s $1 -J -L --output /usr/bin/$2
    chmod a+x /usr/bin/$2
    printf "\t [ DONE ]\n"
}

bin_install $tfdocs terraform-docs
bin_install $awsvault aws-vault

function bin_install_zip {
    printf "    ========[ Install $1 ]========"
    rm -rf /tmp/temp-zip-archive.zip
    curl -s $1 -J -L --output /tmp/temp-zip-archive.zip
    unzip -qq /tmp/temp-zip-archive.zip -d /tmp && rm -f /tmp/temp-zip-archive.zip
    mv /tmp/$2 /usr/bin/
    chmod a+x /usr/bin/$2
    printf "\t [ DONE ]\n"
}


#curl -fLo /usr/bin/yadm https://github.com/TheLocehiliosan/yadm/raw/master/yadm && chmod a+x /usr/bin/yadm

exit 0