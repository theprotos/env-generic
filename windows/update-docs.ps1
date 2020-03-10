iex .\build.ps1 | Import-Module -WarningAction SilentlyContinue
Get-Module Build-WinImage
New-MarkdownHelp -Module Build-WinImage -OutputFolder .\docs -Force
Remove-Module Build-WinImage
