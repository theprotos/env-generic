# env-generic
Yet Another Collection of Generic boxes for common purposes

- Uses automation from [Cookbooks-Generic](https://github.com/theprotos/cookbooks-generic.git)

## Linux
CentOS 7 image with
 - docker ce, docker-compose 
 - awscli, git, terraform, aws-vault
 - disable SELinux

```
linux/build.ps1
cd linux/workspaces/linux-demo
vagrant up
ssh vagrant@host
```
 
 
## Windows

- See initial script [base_setup.ps1](windows/template/scripts/base_setup.ps1)
- [These](https://github.com/theprotos/cookbooks-generic.git) Windows Chef cookbooks will applied, see [apply-cookbooks.ps1](windows/template/scripts/apply-cookbooks.ps1)

### Packer: Build image win10workstation.json

- Update below parameters in [win10workstation.json](windows/template/win10workstation.json)

```
"autounattend": "answer_files/win10ent/Autounattend.xml",
"iso_checksum": "34887592ECC25B725A527748D31971F22C78C82B",
"iso_path"="D:\\home\\downloads\\windows10\\windows11.iso"
```

- Manual run

```
packer build --force -on-error=abort -only=virtualbox-iso  .\win10workstation.json
packer build  -only=virtualbox-iso -var 'iso_path=D:\\home\\downloads\\windows10\\windows11.iso' -var 'iso_checksum=34887592ECC25B725A527748D31971F22C78C82B' .\win10workstation.json
```

- Automated run [build.ps1](windows/template/build.ps1)


# REF

[Create/upload vagrant box](https://www.vagrantup.com/docs/vagrant-cloud/boxes/create.html)

[Windows automated setup](https://docs.microsoft.com/en-us/windows-hardware/manufacture/desktop/automate-windows-setup)