new-module -name Build-WinImage -scriptblock {

    ##Requires -RunAsAdministrator

    <#
        .\build.ps1 | iex; show-help
        .\build.ps1 | iex; build-image -packerConfig .\template\win-2019-1909-dc.json
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
            command [-imageVersion <version>] [-packerConfig <config.json>] [-imageName <win-2019>] [-imageDescription <win image>] [-publish false]

            Available windows configs: $(
        if (Test-Path -Path template -ErrorAction SilentlyContinue) {
            Get-ChildItem template\*.json  -ErrorAction SilentlyContinue | foreach { "`n`t`t" + $_.name }
        }
        else {
            '
                win-10-1903-ent.json
                win-10-1909-ent.json
                win-2019-1809-dc.json
                win-2019-1809-sta.json
                win-2019-1909-dc.json
                win-2019-1909-sta.json

            '
        }
        )

            Available branches:
                master
                development

        USAGE EXAMPLES:
            .\build.ps1 | iex; Build-Image -imageVersion 1.2.3.4 -packerConfig .\template\win-10-2004-ent.json -imageName win-2019 -imageDescription 'basic win image'
            .\build.ps1 | iex; Build-Image -packerConfig .\template\win-10-2004-ent.json
            .\build.ps1 | iex; Build-Image -packerConfig .\template\win-10-2004-ent.json -publish $true

        "
    }

    function Cleanup-Packer {
        Write-Host "$( Get-Date -Format 'yyyy-MM-dd HH:mm' ) ========[ Packer: Clean up ]========"
        Remove-Item -force -recurse -ErrorAction SilentlyContinue metadata.json
        Remove-Item -force -recurse -ErrorAction SilentlyContinue package.box
        Remove-Item -force -recurse -ErrorAction SilentlyContinue boxes\*
        Remove-Item -force -recurse -ErrorAction SilentlyContinue packer_cache\*
        vagrant box prune
    }
    function Add-Vagrant() {
        param(
            [String]
            $imVersion = $imageVersion.trim(),
            [String]
            $imName = $imageName.trim(),
            [String]
            $imDescription = $imageDescription.trim()
        )

        $metadata = "{
    ""name"": ""$imName"",
    ""description"": ""$imDescription"",
    ""versions"": [{
        ""version"": ""$imVersion"",
        ""providers"": [{
            ""name"": ""virtualbox"",
            ""url"": ""package.box""
        }]
    }]
    }"

        Write-Host "$( Get-Date -Format 'yyyy-MM-dd HH:mm' ) ========[ Vagrant: add box: $imName ver: $imVersion ]========"
        $metadata | Out-File metadata.json -Encoding ASCII
        vagrant box add "$($pwd.path)\metadata.json"

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
            $packerConfig = "template\win-10-2004-ent.json",
            [String]
            $imageName = (((Get-Content $packerConfig -Raw -ErrorAction SilentlyContinue) | ConvertFrom-Json).psobject.properties.Value.meta_img_name),
            [String]
            $imageDescription = (((Get-Content $packerConfig -Raw -ErrorAction SilentlyContinue) | ConvertFrom-Json).psobject.properties.Value.meta_img_desc),
            [bool]
            $publish = $false
        )

        cd template
        try {
            Build-Packer $packerConfig
            Add-Vagrant -imageVersion $imageVersion -imageName $imageName -imageDescription $imageDescription
            if($publish){
                Write-Host "$( Get-Date -Format 'yyyy-MM-dd HH:mm' ) ========[ Vagrant: upload $($imageName.trim()):$($imageVersion.trim()) ]========"
                vagrant cloud auth whoami
                vagrant cloud publish isender/$($imageName.trim()) $imageVersion virtualbox package.box -f -r
            }
        }
        catch {
            Write-Error "$( $_.exception.message )"
            throw $_.exception
        }
        finally {
            Cleanup-Packer
            cd ..
        }
    }
    Export-ModuleMember -function 'Build-Image' -alias 'build-image'
    Export-ModuleMember -function 'Show-Help' #-alias 'get-help'

    #show-help
}