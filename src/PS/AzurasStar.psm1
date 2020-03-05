class AzurasStar {
    static [string] $Name
    static [string] $installerPath
    static [string] $installerSrc
    static $Icon
    static [string] $installerDownloads
    static [int32] $FormHeight
    static [int32] $FormWidth
    static [int32] $ColumnPadding
    static [Int32] $RightColumn
    static [Int32] $ButtonHeight
    static [Int32] $ButtonWidth
    [Int32] $CurrentTopOffset
    [Boolean] $firstTopOffset

    AzurasStar() {
        [AzurasStar]::Name = "Azura's Star"
        [AzurasStar]::installerPath = (Get-Item .\).FullName
        [AzurasStar]::installerSrc = "$([AzurasStar]::installerPath)\src"
        $iconLocation = "$([AzurasStar]::installerSrc)\img\azura.ico"
        [AzurasStar]::Icon = New-Object system.drawing.icon($iconLocation)

        # Sizes
        [AzurasStar]::FormHeight = 600
        [AzurasStar]::FormWidth = 1000
        [AzurasStar]::ColumnPadding = 10
        [AzurasStar]::RightColumn = [AzurasStar]::FormWidth/2 + [AzurasStar]::ColumnPadding
        [AzurasStar]::ButtonHeight = 25
        [AzurasStar]::ButtonWidth = 400

        $this.CurrentTopOffset = 0
        $this.firstTopOffset = $true

        $downloads = "$([AzurasStar]::installerPath)\Downloads"
        New-Item -ItemType Directory -Path $downloads -Force
        [AzurasStar]::installerDownloads = (Get-Item $downloads).FullName
    }

    [Int32]
    calculateNextButtonTopOffset() {
        if($this.firstTopOffset -eq $false) {
            $this.CurrentTopOffset = $this.CurrentTopOffset + [AzurasStar]::ButtonHeight + 5
        }
        $this.firstTopOffset = $false
        return $this.CurrentTopOffset
    }
}
