class User {

    [bool]
    isJavaInstalled() {
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

    [bool]
    is7ZipInstalled() {
        if(Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | Where-Object DisplayName -like "7-Zip*") {
            return $true
        } else {
            return $false
        }
    }
}
