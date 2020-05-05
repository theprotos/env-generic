new-module -name Build-LinuxImage -scriptblock {

##Requires -RunAsAdministrator

<#
        .\build.ps1 | iex; show-help
        .\build.ps1 | iex; build-image -packerConfig .\template\win-2019-1909-dc.json
     #>
#>

function Show-Help {
    <#
    .SYNOPSIS
        Helper.
    #>
    Write-Host "
        TOPIC
            Dynamic Module Build-LinuxImage.

        SHORT DESCRIPTION
            Build vagrant image for Linux OS

        USAGE DESCRIPTION
            build.ps1 [-imageVersion <version>] [-imageName <linux-generic>] [-imageDescription <image description>]

        USAGE EXAMPLES:
            .\build.ps1 | Build-Image -imageVersion 1.2.3.4 -imageName linux-generic -imageDescription 'basic linux image'

        "
}

function Vagrant-Package {
    $version = Get-Date -Format "yyyy.MMdd.HHmm"
    $metadata = "{
      ""name"": ""linux-generic"",
      ""description"": ""Linux generic box with preinstalled packages"",
      ""versions"": [{
          ""version"": ""$version"",
          ""providers"": [{
              ""name"": ""virtualbox"",
              ""url"": ""package.box""
          }]
      }]
    }"
    try {
        $metadata | Out-File metadata.json -Encoding ASCII
        Write-Host "$( Get-Date -Format 'yyyy-MM-dd HH:mm' ) ========[ Vagrant: Create box ]========"
        vagrant package
    }
    catch {
        Vagrant-Cleanup
        Write-Error "$( $_.exception.message )"
        throw $_.exception
    }
}

function Vagrant-Cleanup {
    vagrant destroy -f
    Write-Host "$( Get-Date -Format 'yyyy-MM-dd HH:mm' ) ========[ Vagrant: Clean up ]========"
    Remove-Item -force -recurse -ErrorAction SilentlyContinue metadata.json
    Remove-Item -force -recurse -ErrorAction SilentlyContinue package.box
    vagrant box prune
    cd ..
}

# Init
function Build-Image {

    Param(
        $imageVersion = (Get-Date -Format "yyyy.MMdd.HHmm" -ErrorAction SilentlyContinue),
        $imageName = "Linux generic",
        $imageDescription = "no description"
    )

    Write-Host "$( Get-Date -Format 'yyyy-MM-dd HH:mm' ) ========[ Vagrant: STARTED ]========"
    cd template
    try {
        Vagrant-Cleanup
        vagrant up
        Vagrant-Package
    }
    catch {
        Vagrant-Cleanup
        Write-Error "$( $_.exception.message )"
        throw $_.exception
    }

    Write-Host "$( Get-Date -Format 'yyyy-MM-dd HH:mm' ) ========[ Vagrant: Add box ]========"
    vagrant box add metadata.json

    Write-Host "$( Get-Date -Format 'yyyy-MM-dd HH:mm' ) ========[ Vagrant: List of boxes ]========"
    vagrant box list

    Vagrant-Cleanup

    Export-ModuleMember -function 'Build-Image' #-alias 'build-image'
    Export-ModuleMember -function 'Show-Help' #-alias 'get-help'
}}