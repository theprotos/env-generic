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
- [Windows Chef cookbooks](https://github.com/theprotos/cookbooks-generic.git) will applied, see [apply-cookbooks.ps1](windows/template/scripts/apply-cookbooks.ps1)

### Packer: create image

- Update below parameters in respective windows/template/*.json  
```
"autounattend": "answer_files/win10ent/Autounattend.xml",
"iso_checksum": "34887592ECC25B725A527748D31971F22C78C82B",
"iso_path"="D:\\home\\downloads\\windows10\\windows10.iso"
```

- [OPTION 1] Manual run  
```
packer build --force -on-error=abort -only=virtualbox-iso  .\win-10-1903.json
packer build  -only=virtualbox-iso -var 'iso_path=D:\\home\\downloads\\windows10\\windows10.iso' -var 'iso_checksum=34887592ECC25B725A527748D31971F22C78C82B' .\win-10-1903.json
```

- [OPTION 2] Automated run [build.ps1](windows/template/build.ps1)

```
# Run below to get help
.\build.ps1 -help

.\build.ps1 -imageVersion 1.2.3.4 -packerConfig .\template\win10workstation.json -imageName win-2019 -imageDescription 'basic win image'

```

# REF

[Create/upload vagrant box](https://www.vagrantup.com/docs/vagrant-cloud/boxes/create.html)

[Windows automated setup](https://docs.microsoft.com/en-us/windows-hardware/manufacture/desktop/automate-windows-setup)
