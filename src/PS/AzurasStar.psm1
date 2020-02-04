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
}
