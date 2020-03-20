#!/usr/bin/env bash

##################### VARIABLES #####################
tfURL="https://releases.hashicorp.com/terraform/0.12.11/terraform_0.12.11_linux_amd64.zip"
tflint="https://github.com/terraform-linters/tflint/releases/latest/download/tflint_linux_amd64.zip"
tfdocs="https://github.com/segmentio/terraform-docs/releases/latest/download/terraform-docs-v0.6.0-linux-amd64"
awsvault="https://github.com/99designs/aws-vault/releases/latest/download/aws-vault-linux-amd64"
direnv="https://github.com/direnv/direnv/releases/latest/download/direnv.linux-amd64"
vault="https://releases.hashicorp.com/vault/1.1.5/vault_1.1.5_linux_amd64.zip"
helm="https://get.helm.sh/helm-v3.0.0-linux-amd64.tar.gz"
#minikube="https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64"
#####################################################

printf "    ========[ MOTD: Update ]========\n"
printf "Applied from /vagrant/bootstrap-template.sh\n" > /etc/motd
printf "    ==========[ GCP ]==========" >> /etc/motd
printf "\nexport GOOGLE_APPLICATION_CREDENTIALS=" >> /etc/motd
printf "\n    =====[ AWS ]=====                =====[ AZURE ]=====" >> /etc/motd
printf "\nexport AWS_ACCESS_KEY_ID=\t  export client_id=" >> /etc/motd
printf "\nexport AWS_SECRET_ACCESS_KEY=\t  export client_secret=" >> /etc/motd
printf "\nexport AWS_DEFAULT_REGION=\t  export tenant_id=" >> /etc/motd
printf "\n\t\t\t\t  export subscription_id\n" >> /etc/motd
printf "\n\nsudo yum groupinstall -y 'X Window System'" >> /etc/motd
printf "\nsudo yum install gnome-classic-session gnome-terminal nautilus-open-terminal control-center liberation-mono-fonts chrome-gnome-shell firefox" >> /etc/motd


printf "    ========[ SSH: allow password ]========"
sed -i "/^[^#]*PasswordAuthentication[[:space:]]no/c\PasswordAuthentication yes" /etc/ssh/sshd_config
service sshd restart

echo "vagrant ALL=(ALL) NOPASSWD: ALL" | sudo tee -a /etc/sudoers.d/vagrant

printf "    ========[ YUM: Install common packages ]========"
curl -sL https://raw.githubusercontent.com/theprotos/cookbooks-generic/development/scripts/linux.sh | sudo bash -s apply linux-packages.json,linux-docker.json development

pip3 install -q pre-commit

function bin_install {
    printf "    ========[ Install $1 ]========"
    curl -s $1 -J -L --output /usr/bin/$2
    chmod a+x /usr/bin/$2
    printf "\t [ DONE ]\n"
}

bin_install $tfdocs terraform-docs
bin_install $awsvault aws-vault
bin_install $direnv direnv
#bin_install $minikube minikube

function bin_install_zip {
    printf "    ========[ Install $1 ]========"
    rm -rf /tmp/temp-zip-archive.zip
    curl -s $1 -J -L --output /tmp/temp-zip-archive.zip
    unzip -qq /tmp/temp-zip-archive.zip -d /tmp && rm -f /tmp/temp-zip-archive.zip
    mv /tmp/$2 /usr/bin/
    chmod a+x /usr/bin/$2
    printf "\t [ DONE ]\n"
}

bin_install_zip $tfURL terraform
bin_install_zip $tflint tflint
bin_install_zip $vault vault

printf "    ========[ Install $helm ]========"
curl -s $helm  -J -L --output /tmp/helm.tar.gz
tar -xvf /tmp/helm.tar.gz -d /tmp && rm -f /tmp/helm.tar.gz
mv /tmp/linux-amd64/helm /usr/bin/
chmod a+x /usr/bin/helm

curl -fLo /usr/bin/yadm https://github.com/TheLocehiliosan/yadm/raw/master/yadm && chmod a+x /usr/bin/yadm

exit 0