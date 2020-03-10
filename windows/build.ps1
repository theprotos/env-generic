new-module -name Build-WinImage -scriptblock {

    ##Requires -RunAsAdministrator

    <#
        .\build.ps1 | show-help
        .\build.ps1 | build-image -packerConfig .\template\win-2019-1809.json
     #>
     #>

    function Show-Help {
        <#
    .SYNOPSIS
        Helper.
    #>
        Write-Host "
        TOPIC
            Dynamic Module Build-WinImage.

        SHORT DESCRIPTION
            Build vagrant image for Windows OS

        USAGE DESCRIPTION
            build.ps1 [-imageVersion <version>] [-packerConfig <config.json>] [-imageName <win-2019>] [-imageDescription <win image>]

            Available windows configs: $(
        if (Test-Path -Path template -IsValid){
        Get-ChildItem template\*.json  -ErrorAction SilentlyContinue | foreach { "`n`t`t" + $_.name }
        } else {
            '   `nwin-10-1903.json
                win-2019-1809.json
                win-2019-1909.json

            '
        }
        )

            Available branches:
                master
                development

        USAGE EXAMPLES:
            .\build.ps1 | Build-Image -imageVersion 1.2.3.4 -packerConfig .\template\win10workstation.json -imageName win-2019 -imageDescription 'basic win image'

        "
    }

    function Cleanup-Packer {
        Write-Host "$( Get-Date -Format 'yyyy-MM-dd HH:mm' ) ========[ Packer: Clean up ]========"
        Remove-Item -force -recurse -ErrorAction SilentlyContinue metadata.json
        Remove-Item -force -recurse -ErrorAction SilentlyContinue package.box
        Remove-Item -force -recurse -ErrorAction SilentlyContinue boxes\*
        Remove-Item -force -recurse -ErrorAction SilentlyContinue packer_cache\*
    }

    function Add-Vagrant() {

        param(
            [String]
            $imageVersion = $imageVersion,
            [String]
            $imageName = $imageName,
            [String]
            $imageDescription = $imageDescription
        )

        $metadata = "{
    ""name"": ""$imageName"",
    ""description"": ""$imageDescription"",
    ""versions"": [{
        ""version"": ""$imageVersion"",
        ""providers"": [{
            ""name"": ""virtualbox"",
            ""url"": ""package.box""
        }]
    }]
    }"

        Write-Host "$( Get-Date -Format 'yyyy-MM-dd HH:mm' ) ========[ Vagrant: add box $imageName $imageVersion ]========"
        $metadata | Out-File metadata.json -Encoding ASCII
        vagrant box add metadata.json

        Write-Host "$( Get-Date -Format 'yyyy-MM-dd HH:mm' ) ========[ Vagrant: List of boxes ]========"
        vagrant box list
    }

    function Build-Packer() {
        param(
            [String]
            $config = $packerConfig
        )

        Write-Host "$( Get-Date -Format 'yyyy-MM-dd HH:mm' ) ========[ Packer: STARTED $packerConfig ]========"
        packer build --force -only=virtualbox-iso (split-Path $packerConfig -leaf)
    }

function Build-Image {

    Param(
        $imageVersion = (Get-Date -Format "yyyy.MMdd.HHmm" -ErrorAction SilentlyContinue),
        $packerConfig = "template\win10workstation.json",
        $imageName = (((Get-Content $packerConfig -Raw -ErrorAction SilentlyContinue) | ConvertFrom-Json).psobject.properties.Value.meta_img_name),
        $imageDescription = (((Get-Content $packerConfig -Raw -ErrorAction SilentlyContinue) | ConvertFrom-Json).psobject.properties.Value.meta_img_desc)
    )

    cd template
    try {
        Build-Packer $packerConfig
        Add-Vagrant -imageVersion $imageVersion -imageName $imageName -imageDescription $imageDescription

    }
    catch {
        Write-Error "$( $_.exception.message )"
        throw $_.exception
    }
    finally {
        Cleanup-Packer
        cd ..
}

    export-modulemember -function 'Build-Image' #-alias 'build-image'
    export-modulemember -function 'Show-Help' #-alias 'get-help'
}}