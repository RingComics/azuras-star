# Some users Windows Policy may disable them from running scripts, temporarily disable that
Set-ExecutionPolicy Bypass -Scope Process

# Run the installer
& .\src\installer.ps1
