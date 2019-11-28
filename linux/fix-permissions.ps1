# Set Variable #
$key="D:/home/.vagrant.d/boxes/linux-generic/2019.1018.1723/virtualbox/vagrant_private_key"

Get-ChildItem $key

# Remove Inheritance #
icacls $key /c /t /inheritance:d

# Set Ownership to Owner #
cmd /c icacls $key /c /t /grant %username%:F

# Remove All Users, except for Owner #
cmd /c icacls $key  /c /t /remove Administrator "Authenticated Users" BUILTIN\Administrators BUILTIN Everyone System Users

# Verify #
cmd /c icacls $key
