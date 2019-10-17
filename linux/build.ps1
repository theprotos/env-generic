$metadata = '{
    "name": "linux-generic",
    "description": "Linux generic box with preinstalled packages",
    "versions": [{
        "version": "0.1.0",
        "providers": [{
            "name": "virtualbox",
            "url": "package.box"
        }]
    }]
}
'
cd template
$metadata | Out-File metadata.json -Encoding ASCII

vagrant up
vagrant package
vagrant box add metadata.json
vagrant box list

Remove-Item -force -recurse .vagrant
Remove-Item -force -recurse metadata.json
Remove-Item -force -recurse package.box

cd ..
