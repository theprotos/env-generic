function Vagrant-Package
{
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
    try
    {
        $metadata | Out-File metadata.json -Encoding ASCII
        Write-Host "$( Get-Date -Format 'yyyy-MM-dd HH:mm' ) ========[ Vagrant: Create box ]========"
        vagrant package
    }
    catch
    {
        Vagrant-Cleanup
        Write-Error "$( $_.exception.message )"
        throw $_.exception
    }
}

function Vagrant-Cleanup
{
    vagrant destroy -f
    Write-Host "$( Get-Date -Format 'yyyy-MM-dd HH:mm' ) ========[ Vagrant: Clean up ]========"
    Remove-Item -force -recurse -ErrorAction SilentlyContinue metadata.json
    Remove-Item -force -recurse -ErrorAction SilentlyContinue package.box
}

Write-Host "$( Get-Date -Format 'yyyy-MM-dd HH:mm' ) ========[ Vagrant: STARTED ]========"
cd template
try
{
    vagrant up
    Vagrant-Package
}
catch
{
    Vagrant-Cleanup
    Write-Error "$( $_.exception.message )"
    throw $_.exception
}

Write-Host "$( Get-Date -Format 'yyyy-MM-dd HH:mm' ) ========[ Vagrant: Add box ]========"
vagrant box add metadata.json

Write-Host "$( Get-Date -Format 'yyyy-MM-dd HH:mm' ) ========[ Vagrant: List of boxes ]========"
vagrant box list

Vagrant-Cleanup
cd ..

