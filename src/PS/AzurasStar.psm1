class AzurasStar {
    static [string] $Name
    static [string] $installerPath
    static [string] $installerSrc
    static $Icon
    static [string] $installerDownloads
    AzurasStar() {
        [AzurasStar]::Name = "Azura's Star"
        [AzurasStar]::installerPath = (Get-Item .\).FullName
        [AzurasStar]::installerSrc = "$([AzurasStar]::installerPath)\src"
        $iconLocation = "$([AzurasStar]::installerSrc)\img\azura.ico"
        [AzurasStar]::Icon = New-Object system.drawing.icon($iconLocation)

        $downloads = "$([AzurasStar]::installerPath)\Downloads"
        New-Item -ItemType Directory -Path $downloads -Force
        [AzurasStar]::installerDownloads = (Get-Item $downloads).FullName
    }

    [bool]
    testJava(){
        if(Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | Where-Object DisplayName -like "Java*") {
            if(Test-Path "$env:ProgramFiles\Java") {
                return $true
            } else {
                # 32 bit Java is installed which won't work
                return $false
            }
        } else {
           return $false
        }
    }
}
