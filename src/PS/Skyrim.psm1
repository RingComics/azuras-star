Using module .\AzurasStar.psm1

class Skyrim {

    static [Array] $DLC

    $MessageBox
    $AzurasStar
    [String] $installPath
    [bool] $multipleInstalls

    Skyrim($messageBox, $AzurasStar) {
        $this.MessageBox = $messageBox
        $this.AzurasStar = $AzurasStar

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
            $this.MessageBox::Show("Could not automatically detect a valid Skyrim install, please enter one manually", [AzurasStar]::Name);
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
            $this.MessageBox::Show("Could not automatically detect a valid Skyrim install, please enter one manually", [AzurasStar]::Name);
            $this.setInstallationPath($this.enterInstallPathManually(), $false)
        } elseif(![Skyrim]::validSkyrimInstall($this.installPath)) {
            $this.MessageBox::Show("Not a valid Skyrim LE install path, please ensure you select the root skyrim folder that contains a TESV.exe", [AzurasStar]::Name);
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

    cleanDLC() {
        $modInstallPath = [AzurasStar]::getModInstallPath($this.installPath)

        $this.AzurasStar.writeDebugMessage("Starting ModOrganizer to create ini")
        $this.MessageBox::Show("ModOrganizer will launch and then close multiple times while cleaning DLCs.`r`nDismiss developer pop-ups if they come up and are preventing TES5Edit from running, otherwise do not touch your mouse or keyboard.`r`nConsider supporting the TES5Edit project!", [AzurasStar]::Name)
        Start-Process "$($this.installPath)\US\$modInstallPath\ModOrganizer.exe"
        Start-Sleep -Seconds 5
        Stop-Process -Name ModOrganizer
        $modOrganizerIni = (Get-Content -Path "$($this.installPath)\US\$modInstallPath\ModOrganizer.ini")
        $numberOfEXE = ""
        foreach($line in $modOrganizerIni) {
            if($line -like "size=*") {
                $temp = [int]($line -replace "size=", "")
                if($temp -gt 0) {
                    $numberOfEXE = $temp
                }
            }
        }

        $newEXEs = ""
        $i = $numberOfEXE + 1
        $DLCPATH = $this.installPath -replace '\\', "/"
        foreach($DLC in [Skyrim]::DLC) {
            $newEXEs = $newEXEs + "$i\title=Clean $DLC`r`n$i\toolbar=false`r`n$i\ownicon=true`r`n$i\binary=$DLCPATH/US/Utilities/TES5Edit.exe`r`n$i\arguments=`"-autoexit -quickautoclean -autoload $DLC.esm`"`r`n$i\workingDirectory=`r`n$i\steamAppID=`r`n"
            $i++
        }
        $newEXEs = $newEXEs + "size=$($i - 1)"
        (Get-Content -Path "$($this.installPath)\US\$modInstallPath\ModOrganizer.ini" -Raw) -replace "size=$numberOfEXE", $newEXEs | Set-Content -Path "$($this.installPath)\US\$modInstallPath\ModOrganizer.ini"
        (Get-Content -Path "$($this.installPath)\US\$modInstallPath\ModOrganizer.ini" -Raw) + "[Settings]`r`nlanguage=en`r`noverwritingLooseFilesColor=@Variant(\0\0\0\x43\x1@@\xff\xff\0\0\0\0\0\0)`r`noverwrittenLooseFilesColor=@Variant(\0\0\0\x43\x1@@\0\0\xff\xff\0\0\0\0)`r`noverwritingArchiveFilesColor=@Variant(\0\0\0\x43\x1@@\xff\xff\0\0\xff\xff\0\0)`r`noverwrittenArchiveFilesColor=@Variant(\0\0\0\x43\x1@@\0\0\xff\xff\xff\xff\0\0)`r`ncontainsPluginColor=@Variant(\0\0\0\x43\x1@@\0\0\0\0\xff\xff\0\0)`r`ncontainedColor=@Variant(\0\0\0\x43\x1@@\0\0\0\0\xff\xff\0\0)`r`ncompact_downloads=false`r`nmeta_downloads=false`r`nuse_prereleases=false`r`ncolorSeparatorScrollbars=true`r`nlog_level=1`r`ncrash_dumps_type=1`r`ncrash_dumps_max=5`r`noffline_mode=false`r`nuse_proxy=false`r`nendorsement_integration=true`r`nhide_api_counter=false`r`nload_mechanism=0`r`nhide_unchecked_plugins=false`r`nforce_enable_core_files=true`r`ndisplay_foreign=true`r`nlock_gui=false`r`narchive_parsing_experimental=false" | Set-Content -Path "$($this.installPath)\US\$modInstallPath\ModOrganizer.ini"
        $this.AzurasStar.writeDebugMessage("Created mod organiser inis")

        $this.AzurasStar.writeDebugMessage("Cleaning DLCs")
        foreach($dlc in [Skyrim]::DLC) {
            $this.AzurasStar.writeDebugMessage("Cleaning $dlc.esm")
            $cleaning = Start-Process "$($this.installPath)\US\$modInstallPath\ModOrganizer.exe" -ArgumentList "-p `"$modInstallPath`" `"moshortcut://:Clean $dlc`"" -PassThru
            Wait-Process -Id $cleaning.Id
            Wait-Process TES5Edit
        }
        $this.AzurasStar.writeDebugMessage("All DLCs cleaned")
    }
}
