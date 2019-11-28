$version = Get-Date -Format "yyyy.MMdd.HHmm"
$metadata = "{
    ""name"": ""windows-generic"",
    ""description"": ""Windows generic box with preinstalled packages"",
    ""versions"": [{
        ""version"": ""$version"",
        ""providers"": [{
            ""name"": ""virtualbox"",
            ""url"": ""package.box""
        }]
    }]
}"

function Cleanup-Packer {
    Write-Host "$( Get-Date -Format 'yyyy-MM-dd HH:mm' ) ========[ Packer: Clean up ]========"
    Remove-Item -force -recurse -ErrorAction SilentlyContinue metadata.json
    Remove-Item -force -recurse -ErrorAction SilentlyContinue package.box
    Remove-Item -force -recurse -ErrorAction SilentlyContinue boxes\*
    Remove-Item -force -recurse -ErrorAction SilentlyContinue packer_cache\*
}

function Add-Vagrant() {
    Write-Host "$( Get-Date -Format 'yyyy-MM-dd HH:mm' ) ========[ Vagrant: add box ]========"
    $metadata | Out-File metadata.json -Encoding ASCII
    vagrant box add metadata.json

    Write-Host "$( Get-Date -Format 'yyyy-MM-dd HH:mm' ) ========[ Vagrant: List of boxes ]========"
    vagrant box list
}

function Build-Packer() {
    param(
        [String]
        $config = ".\win10workstation.json"
    )

    Write-Host "$( Get-Date -Format 'yyyy-MM-dd HH:mm' ) ========[ Packer: STARTED ]========"
    packer build --force -only=virtualbox-iso  $config
}

cd template
try {
    Build-Packer ".\win10workstation.json"
    Add-Vagrant

}
catch {
    Write-Error "$( $_.exception.message )"
    throw $_.exception
}
finally {
    Cleanup-Packer
    cd ..
}


