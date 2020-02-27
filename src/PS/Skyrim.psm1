Using module .\AzurasStar.psm1

class Skyrim {

    static [Array] $DLC

    $MessageBox
    [String] $installPath
    [bool] $multipleInstalls

    Skyrim($messageBox) {
        $this.MessageBox = $messageBox

        [Skyrim]::DLC = @(
        "Update",
        "Dawnguard",
        "Hearthfires",
        "Dragonborn"
        )
    }

    setInstallationPath($paths, $autoDetected) {
        # If there are multiple versions of Skyrim in the registry, let the user pick the correct one
        if($paths -eq $null) {
            $this.MessageBox::Show("Could not automatically detect a valid Skyrim install, please enter one manually", "Azura's Star Install");
            $this.setInstallationPath($this.enterInstallPathManually(), $false)
        } elseif($paths -is [string]) {
            $this.installPath = $paths
        } else {
            $this.multipleInstalls = $true
            $this.installPath = $this.getPathFromList($paths)
        }

        #TODO Check that it is not installed in program files and warn user if it is
        if(![Skyrim]::validSkyrimInstall($this.installPath) -and $this.multipleInstalls) {
            $dialogResult = $this.MessageBox::Show("The selected path is not valid, it must contain a TESV.exe and NOT be in Program Files. Select yes to pick again or no to enter manually", "Ultimate Skyrim Install", "YesNo");
            if($dialogResult -eq "Yes") {
                $this.setInstallationPath($paths, $autoDetected)
            } else {
                $this.setInstallationPath($this.enterInstallPathManually(), $false)
            }
        } elseif(![Skyrim]::validSkyrimInstall($this.installPath) -and $autoDetected -eq $true) {
            $this.MessageBox::Show("Could not automatically detect a valid Skyrim install, please enter one manually", "Azura's Star Install");
            $this.setInstallationPath($this.enterInstallPathManually(), $false)
        } elseif(![Skyrim]::validSkyrimInstall($this.installPath)) {
            $this.MessageBox::Show("Not a valid Skyrim LE install path, please ensure you select the root skyrim folder that contains a TESV.exe", "Azura's Star Install");
            $this.setInstallationPath($this.enterInstallPathManually(), $false)
        }
    }

    [String]
    enterInstallPathManually() {
        $localInstallPath = ""
        $configFormGetInstallPath = New-Object System.Windows.Forms.Form
        $configFormGetInstallPath.Width = 500
        $configFormGetInstallPath.Height = 300
        $configFormGetInstallPath.Text = "Azura's Star - Skyrim install path"
        $configFormGetInstallPath.Icon = [AzurasStar]::Icon
        $configFormGetInstallPath.FormBorderStyle = "Fixed3D"
        $configFormGetInstallPath.MaximizeBox = $false
        $configFormGetInstallPath.MinimizeBox = $false
        $configFormGetInstallPath.TopMost = $true
        $getInstallPath = New-Object System.Windows.Forms.TextBox
        $getInstallPath.Top = 10
        $getInstallPath.Left = 10
        $getInstallPath.Size = New-Object System.Drawing.Size(300)
        $getInstallPath.Multiline = $false
        $configFormGetInstallPath.Controls.Add($getInstallPath)

        $selectPath = New-Object System.Windows.Forms.Button
        $selectPath.Text = "Select"
        $selectPath.Top = 70
        $selectPath.Left = 97.5
        $selectPath.ADD_CLICK({
            Set-Variable -scope 1 -Name "localInstallPath" -Value $getInstallPath.Text
            $configFormGetInstallPath.Close()
        })
        $configFormGetInstallPath.Controls.Add($selectPath)
        $configFormGetInstallPath.ShowDialog()

        return $localInstallPath
    }

    [String]
    getPathFromList($paths) {
        $localInstallPath = ""

        $Form = New-Object System.Windows.Forms.Form
        $Form.Icon = [AzurasStar]::Icon
        $Form.Text = "Select Skyrim SE location"
        $Form.AutoSize = $true

        $DropDownLabel = new-object System.Windows.Forms.Label
        $DropDownLabel.AutoSize = $true;
        $DropDownLabel.Text = "We detected multiple versions of Skyrim on your machine.`r`nPlease select the correct Skyrim LE installation:"

        $DropDown = new-object System.Windows.Forms.ComboBox
        ForEach($path in $paths) {
            [void] $DropDown.Items.Add($path)
        }
        $DropDown.DropDownStyle = "DropDownList"
        $DropDown.SelectedItem = $DropDown.Items[0]
        $DropDown.Size = new-object System.Drawing.Size(GetDropDownWidth($DropDown), 10)

        $Button = new-object System.Windows.Forms.Button
        $Button.Text = "Select"
        $Button.Add_Click({
            Set-Variable -scope 1 -Name "localInstallPath" -Value $DropDown.SelectedItem.ToString()
            $Form.Close()
        })

        $LayoutPanel = New-Object System.Windows.Forms.FlowLayoutPanel
        $LayoutPanel.AutoSize = $true
        $LayoutPanel.Controls.Add($DropDownLabel);
        $LayoutPanel.Controls.Add($DropDown)
        $LayoutPanel.Controls.Add($Button)
        $LayoutPanel.FlowDirection = "TopDown"

        $Form.controls.add($LayoutPanel)

        $Form.Add_Shown({$Form.Activate()})
        [void] $Form.ShowDialog()

        return $localInstallPath
    }

    [bool]
    static
    validSkyrimInstall($path) {
        if([Skyrim]::testTESVexe($path)) {
            return $true
        } else {
            return $false
        }
    }

    [bool]
    static
    testTESVexe($path) {
        $return = Test-Path "$($path)\TESV.exe"
        return $return
    }

    static
    [PSObject]
    getSkyrimInstalledPaths() {
        return Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | Where-Object DisplayName -eq "The Elder Scrolls V: Skyrim" | Select-Object -ExpandProperty InstallLocation
    }
}
