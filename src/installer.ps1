Using module .\PS\AzurasStar.psm1
Using module .\PS\Skyrim.psm1
Using module .\PS\User.psm1
Using module .\PS\enb.psm1
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.IO.Compression.FileSystem #Zip Compression
Import-Module .\src\PS\PSUtils.psm1

$AzurasStar = [AzurasStar]::new()

#Azura's Star main form
$configForm = New-Object System.Windows.Forms.Form
$configForm.Width = [AzurasStar]::FormWidth
$configForm.Height = [AzurasStar]::FormHeight
$configForm.Text = [AzurasStar]::Name
$configForm.MaximizeBox = $false
$configForm.MinimizeBox = $false
$configForm.FormBorderStyle = 'Fixed3D'
$configForm.Icon = [AzurasStar]::Icon

#Configure debug window so subsequent dependencies can use it
$debugConsole = New-Object System.Windows.Forms.RichTextBox
$debugConsole.Top = 0
$debugConsole.Left = 10
$debugConsoleHeight = [AzurasStar]::FormHeight - 50
$debugConsoleWidth = [AzurasStar]::FormWidth/2 - [AzurasStar]::ColumnPadding
$debugConsole.Size = New-Object System.Drawing.Size($debugConsoleWidth, $debugConsoleHeight)
$debugConsole.ReadOnly = $true
$configForm.Controls.Add($debugConsole)
$AzurasStar.setDebugConsole($debugConsole)

#Other dependencies
$Skyrim = [Skyrim]::new([Windows.Forms.MessageBox],$AzurasStar)
$Skyrim.setInstallationPath([Skyrim]::getSkyrimInstalledPaths(), $true)
$CurrentUser = [User]::new()
$ENB = [ENB]::new([Windows.Forms.MessageBox],$AzurasStar, $Skyrim)

$AzurasStar.writeDebugMessage("Install Path: $($Skyrim.installPath)\US")
$AzurasStar.writeDebugMessage("Download Path: $($Skyrim.installPath)\US\Downloads")

switch($CurrentUser.isJavaInstalled() -eq $true) {
    $true{
        $AzurasStar.writeDebugMessage("Java already installed")
    }
    $false{
        $configFormPreReqsJava = New-Object System.Windows.Forms.Button
        $configFormPreReqsJava.Top = $AzurasStar.calculateNextButtonTopOffset()
        $configFormPreReqsJava.Left = [AzurasStar]::RightColumn
        $configFormPreReqsJava.Size = New-Object System.Drawing.Size([AzurasStar]::ButtonWidth, [AzurasStar]::ButtonHeight)
        $configFormPreReqsJava.ADD_CLICK({
            Start-Process "$([AzurasStar]::installerSrc)\bin\jre-8u231-windows-x64.exe"
            $AzurasStar.writeDebugMessage("Installing Java")
        })
        $configForm.Controls.Add($configFormPreReqsJava)
        $configFormPreReqsJava.Text = "Install Java"
    }
}

switch($CurrentUser.is7ZipInstalled() -eq $true) {
    $true {
        $AzurasStar.writeDebugMessage("7-Zip already Installed")
    }
    $false {
        $configFormPreReqs7zip = New-Object System.Windows.Forms.Button
        $configFormPreReqs7zip.Top = $AzurasStar.calculateNextButtonTopOffset()
        $configFormPreReqs7zip.Left = [AzurasStar]::RightColumn
        $configFormPreReqs7zip.Size = New-Object System.Drawing.Size([AzurasStar]::ButtonWidth, [AzurasStar]::ButtonHeight)
        $configFormPreReqs7zip.ADD_CLICK({
            Start-Process "$([AzurasStar]::installerSrc)\bin\7z1900-x64.exe"
            $AzurasStar.writeDebugMessage("Installing 7-Zip")
        })
        $configForm.Controls.Add($configFormPreReqs7zip)

        $configFormPreReqs7zip.Text = "Install 7-Zip"
    }
}
$configFormPreReqsSkyrim = New-Object System.Windows.Forms.Button
$configFormPreReqsSkyrim.Text = "Run Skyrim once"
$configFormPreReqsSkyrim.Top = $AzurasStar.calculateNextButtonTopOffset()
$configFormPreReqsSkyrim.Left = [AzurasStar]::RightColumn
$configFormPreReqsSkyrim.Size = New-Object System.Drawing.Size([AzurasStar]::ButtonWidth, [AzurasStar]::ButtonHeight)
$configFormPreReqsSkyrim.ADD_CLICK({
    [Windows.Forms.MessageBox]::Show("When Skyrim launches, let it automatically detect your settings, then launch to the main menu. Then you can exit Skyrim and come back here to run the Preinstall.", "Ultimate Skyrim Install", [Windows.Forms.MessageBoxButtons]::OK, [Windows.Forms.MessageBoxIcon]::Information)
    $AzurasStar.writeDebugMessage("Launching Skyrim for first time set up")
    $steamPath = (Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | Where-Object DisplayName -Like "Steam" | Select-Object -ExpandProperty UninstallString) -replace "uninstall.exe", "steam.exe"
    $configFormPreReqsSkyrim.Enabled = $false
    Start-Process $steamPath -ArgumentList "-applaunch 72850" -Wait
    Start-Sleep -Seconds 5
    Wait-Process -Name SkyrimLauncher -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 5
    Wait-Process -Name TESV -ErrorAction SilentlyContinue
    if($CurrentUser.isJavaInstalled() -eq $true -and $CurrentUser.is7ZipInstalled()) {
        $configFormPreReqsPreinstall.Enabled = $true
        $AzurasStar.writeDebugMessage("You may now run the Preinstall")

    } else {
        [Windows.Forms.MessageBox]::Show("Java and 7-Zip must be installed before you can run the Preinstall. Please install them and restart the installer", "Ultimate Skyrim Install", [Windows.Forms.MessageBoxButtons]::OK, [Windows.Forms.MessageBoxIcon]::Error)
        $AzurasStar.writeDebugMessage("Java and 7-Zip must be installed before you can run the Preinstall. Please install them and restart the installer")
    }
})
$configForm.Controls.Add($configFormPreReqsSkyrim)

$configFormPreReqsPreinstall = New-Object System.Windows.Forms.Button
$configFormPreReqsPreinstall.Enabled = $false
$configFormPreReqsPreinstall.Text = "Run Preinstall"
$configFormPreReqsPreinstall.Top = $AzurasStar.calculateNextButtonTopOffset()
$configFormPreReqsPreinstall.Left = [AzurasStar]::RightColumn
$configFormPreReqsPreinstall.Size = New-Object System.Drawing.Size([AzurasStar]::ButtonWidth, [AzurasStar]::ButtonHeight)
$configFormPreReqsPreinstall.ADD_CLICK({

    $AzurasStar.writeDebugMessage("Getting Nexus API key")
    [Windows.Forms.MessageBox]::Show("Some mods need to be downloaded from Nexus, this requires a Nexus Personal API Key which is given to premium Nexus accounts only. This is private to you and we don't save it, we just pass it through to Nexus.`r`n`r`nDO NOT SHARE THIS WITH ANYONE!`r`n`r`nYou can find your Personal API Key at the bottom of the page that will open in your default browser after clicking ok. Paste it into the pop up window.", "Ultimate Skyrim Install", [Windows.Forms.MessageBoxButtons]::OK, [Windows.Forms.MessageBoxIcon]::Information)
    Start-Process "https://www.nexusmods.com/users/myaccount?tab=api%20access"
    Start-Sleep -Seconds 2
    $configFormGetAPIKey = New-Object System.Windows.Forms.Form
    $configFormGetAPIKey.Width = 288
    $configFormGetAPIKey.Height = 140
    $configFormGetAPIKey.Text = "Azura's Star - Personal API Key"
    $configFormGetAPIKey.Icon = [AzurasStar]::Icon
    $configFormGetAPIKey.FormBorderStyle = "Fixed3D"
    $configFormGetAPIKey.MaximizeBox = $false
    $configFormGetAPIKey.MinimizeBox = $false
    $configFormGetAPIKey.TopMost = $true
    $getAPIKey = New-Object System.Windows.Forms.TextBox
    $getAPIKey.Top = 10
    $getAPIKey.Left = 10
    $getAPIKey.Size = New-Object System.Drawing.Size(250, 50)
    $getAPIKey.AutoSize = $false;
    $getAPIKey.Multiline = $true
    $configFormGetAPIKey.Controls.Add($getAPIKey)

    $confirmAPIKey = New-Object System.Windows.Forms.Button
    $confirmAPIKey.Text = "Continue"
    $confirmAPIKey.Top = 70
    $confirmAPIKey.Left = 97.5
    $confirmAPIKey.ADD_CLICK({
        $global:apiKey = $getAPIKey.Text
        $AzurasStar.writeDebugMessage("Got Nexus API key")
        $configFormGetAPIKey.Close()
    })
    $configFormGetAPIKey.Controls.Add($confirmAPIKey)
    $configFormGetAPIKey.ShowDialog()

    $AzurasStar.writeDebugMessage("Creating install directories")
    New-Item -ItemType Directory -Path "$($Skyrim.installPath)\US" -Force
    New-Item -ItemType Directory -Path "$($Skyrim.installPath)\US\Utilities" -Force
    New-Item -ItemType Directory -Path "$($Skyrim.installPath)\US\Downloads" -Force

    $AzurasStar.writeDebugMessage("Copying ENB files...")
    Copy-Item -Path "$([AzurasStar]::installerSrc)\bin\d3d9.dll" -Destination $Skyrim.installPath -Force
    Copy-Item -Path "$([AzurasStar]::installerSrc)\bin\enbhost.exe" -Destination $Skyrim.installPath -Force
    Copy-Item -Path "$([AzurasStar]::installerSrc)\bin\enblocal.ini" -Destination $Skyrim.installPath -Force
    $AzurasStar.writeDebugMessage("Copied ENB files")

    $AzurasStar.writeDebugMessage("Getting VideoMemory")
    $RAM = $ENB.getRAM()
    $VRAM = $ENB.getVRAM()
    $videoMemory = $ENB.getVideoMemory($RAM, $VRAM)
    $AzurasStar.writeDebugMessage("Setting enb preset")
    $AzurasStar.writeDebugMessage("RAM: $RAM")
    $AzurasStar.writeDebugMessage("VRAM: $VRAM")
    $AzurasStar.writeDebugMessage("Video Memory: $videoMemory")
    $enbPreset = $ENB.detectENBPreset($videoMemory)
    $AzurasStar.writeDebugMessage("ENB preset: $enbPreset")
    $AzurasStar.writeDebugMessage("Setting VideoMemory in enblocal.ini")
    (Get-Content -Path "$([AzurasStar]::installerSrc)\bin\enblocal.ini" -raw) -replace "INSERTRAMHERE", $videoMemory | Set-Content "$($Skyrim.installPath)\enblocal.ini"

    $AzurasStar.writeDebugMessage("Copying Ultimate Skyrim specific files")
    foreach($file in (Get-ChildItem -Path "$([AzurasStar]::installerSrc)\ultsky")) {
        Copy-Item -Path $file.FullName -Destination "$($Skyrim.installPath)\US\Downloads" -Force
    }
    Copy-Item -Path "$([AzurasStar]::installerSrc)\bin\US 406hf2 Gamepad - LD Hotfix 1.auto" -Destination "$($Skyrim.installPath)\US" -Force
    Copy-Item -Path "$([AzurasStar]::installerSrc)\bin\US 406hf2 Keyboard - LD Hotfix 1.auto" -Destination "$($Skyrim.installPath)\US" -Force

    $AzurasStar.writeDebugMessage("Starting manual downloads, this might take a few minutes. This sometimes causes the window to not respond even though it's still working. Be patient :)")

    if(!(Test-Path "$([AzurasStar]::installerDownloads)\skse_1_07_03.7z")) {
        $AzurasStar.writeDebugMessage("Downloading SKSE...")
        Invoke-WebRequest -Uri "https://skse.silverlock.org/beta/skse_1_07_03.7z" -OutFile "$([AzurasStar]::installerDownloads)\SKSE_install.7z"
        $AzurasStar.writeDebugMessage("Downloaded SKSE")
    } else {
        $AzurasStar.writeDebugMessage("SKSE already downloaded")
    }

    if(!(Test-Path "$([AzurasStar]::installerDownloads)\SKSEPreloader.zip")) {
        $AzurasStar.writeDebugMessage("Downloading SKSE preloader...")
        $preloaderDownloadLink = Invoke-RestMethod -Uri "https://api.nexusmods.com/v1/games/skyrim/mods/75795/files/1000207412/download_link.json" -Headers @{"apikey" = "$apiKey"}
        Invoke-WebRequest -Uri $preloaderDownloadLink[0].URI -OutFile "$([AzurasStar]::installerDownloads)\SKSEPreloader.zip"
        $AzurasStar.writeDebugMessage("Downloaded SKSE prelopader")
    } else {
        $AzurasStar.writeDebugMessage("SKSE prelaoder already downloaded")
    }

    if(!(Test-Path "$($Skyrim.installPath)\skse_loader.exe")) {
        $AzurasStar.writeDebugMessage("Installing SKSE...")
        & "$env:ProgramFiles\7-Zip\7z.exe" "x" "`"$([AzurasStar]::installerDownloads)\SKSE_install.7z`"" "-aoa" "-o`"$([AzurasStar]::installerDownloads)`"" > $null
        Get-ChildItem -Path "$([AzurasStar]::installerDownloads)\skse_1_07_03" | Copy-Item -Destination $Skyrim.installPath -Recurse -Container -Force
        $AzurasStar.writeDebugMessage("Installed SKSE")
    } else {
        $AzurasStar.writeDebugMessage("SKSE already installed")
    }

    if(!(Test-Path "$($Skyrim.installPath)\d3dx9_42.dll")) {
        $AzurasStar.writeDebugMessage("Installing SKSE preloader...")
        $SKSEzip = Get-Item "$([AzurasStar]::installerDownloads)\SKSEPreloader.zip"
        [System.IO.Compression.ZipFile]::ExtractToDirectory($SKSEzip.FullName, $Skyrim.installPath)
        $AzurasStar.writeDebugMessage("Installed SKSE preloader")
    } else {
        $AzurasStar.writeDebugMessage("SKSE preloader already installed")
    }

    if(!(Test-Path -Path "$([AzurasStar]::installerDownloads)\TES5Edit.7z")) {
        $AzurasStar.writeDebugMessage("Downloading TES5Edit...")
        $TES5EditDownloadLink = Invoke-RestMethod -Uri "https://api.nexusmods.com/v1/games/skyrim/mods/25859/files/1000309592/download_link.json" -Headers @{"apikey" = "$apiKey"}
        Invoke-WebRequest -Uri $TES5EditDownloadLink[0].URI -OutFile "$([AzurasStar]::installerDownloads)\TES5Edit.7z"
        $AzurasStar.writeDebugMessage("Downloaded TES5Edit")
    } else {
        $AzurasStar.writeDebugMessage("TES5Edit already downloaded")
    }

    if(!(Test-Path -Path "$($Skyrim.installPath)\US\Utilities\TES5Edit.exe")) {
        $AzurasStar.writeDebugMessage("Extracting TES5Edit...")
        & "$env:ProgramFiles\7-Zip\7z.exe" "x" "$([AzurasStar]::installerDownloads)/TES5Edit.7z" "-aoa" "-o$($Skyrim.installPath)\US\Utilities" > $null
        Remove-Item "$([AzurasStar]::installerDownloads)\TES5Edit.7z"
        $AzurasStar.writeDebugMessage("Extracted TES5Edit")
    } else {
        $AzurasStar.writeDebugMessage("TES5Edit already installed")
    }

    if(!(Test-Path "$($Skyrim.installPath)\US\Downloads\NVAC - New Vegas Anti Crash-53635-7-5-1-0.zip")) {
        $AzurasStar.writeDebugMessage("Downloading NVAC...")
        $NVACDownloadLink = Invoke-RestMethod -Uri "https://api.nexusmods.com/v1/games/newvegas/mods/53635/files/1000039152/download_link.json" -Headers @{"apikey" = "$apiKey"}
        Invoke-WebRequest -Uri $NVACDownloadLink[0].URI -OutFile "$($Skyrim.installPath)\US\Downloads\NVAC - New Vegas Anti Crash-53635-7-5-1-0.zip"
        $AzurasStar.writeDebugMessage("Downloaded NVAC")
    } else {
        $AzurasStar.writeDebugMessage("NVAC already downloaded")
    }

    if(!(Test-Path "$($Skyrim.installPath)\US\Downloads\Wyrmstooth 1.17B.zip")) {
        $AzurasStar.writeDebugMessage("Downloading Wyrmstooth...")
        Invoke-WebRequest -Uri "https://archive.org/download/Wyrmstooth1.17B/Wyrmstooth%201.17B.zip" -OutFile "$($Skyrim.installPath)\US\Downloads\Wyrmstooth 1.17B.zip"
        $AzurasStar.writeDebugMessage("Downloaded Wyrmstooth")
    } else {
        $AzurasStar.writeDebugMessage("Wyrmstooth already downloaded")
    }

    if(!(Test-Path -Path "$($Skyrim.installPath)\US\Downloads\US 4.0.6hf2 DynDOLOD.rar")) {
        [Windows.Forms.MessageBox]::Show("Due to the size of DynDOLOD, it must be downloaded manually. You will be directed to the download page. Please drag and drop the file into the downloads folder that will open when you hit OK", "Ultimate Skyrim Install", [Windows.Forms.MessageBoxButtons]::OK, [Windows.Forms.MessageBoxIcon]::Information)
        Start-Process "https://mega.nz/#!SANlQY7R!deorWwQBDDw4GoHYfJ-7NJVOWQ1U-KsoH1HrdG4PFaI"
        Invoke-Item "$($Skyrim.installPath)\US\Downloads"
        $AzurasStar.writeDebugMessage("Waiting for DynDOLOD to be downloaded")
        while(!(Test-Path -Path "$($Skyrim.installPath)\US\Downloads\US 4.0.6hf2 DynDOLOD.rar")) {
        }
        $AzurasStar.writeDebugMessage("DynDOLOD downloaded")
        [Windows.Forms.MessageBox]::Show("Now you can run Automaton!", "Ultimate Skyrim Install", [Windows.Forms.MessageBoxButtons]::OK, [Windows.Forms.MessageBoxIcon]::Information)
    } else {
        $AzurasStar.writeDebugMessage("DynDOLOD already downloaded")
    }
    $AzurasStar.writeDebugMessage("Ready to run Automaton! Double check your settings and rerun Preinstall if you need to change something")
    $startAutomaton.Enabled = $true
})
$configForm.Controls.Add($configFormPreReqsPreinstall)

$startAutomaton = New-Object System.Windows.Forms.Button
$startAutomaton.Enabled = $false
$startAutomaton.Text = "Run Automaton"
$startAutomaton.Top = $AzurasStar.calculateNextButtonTopOffset()
$startAutomaton.Left = [AzurasStar]::RightColumn
$startAutomaton.Size = New-Object System.Drawing.Size([AzurasStar]::ButtonWidth, [AzurasStar]::ButtonHeight)
$startAutomaton.ADD_CLICK({
    $AzurasStar.writeDebugMessage("Running Automaton")
    [Windows.Forms.MessageBox]::Show("When Automaton launches, select either Keyboard or Gamepad from $($Skyrim.installPath)\US and then copy the install and download paths into their respective fields.`r`nAllow Automaton to access your Nexus account and handle NXM links (required). If you are a Nexus premium member, Automaton can download each mod for you automatically by clicking on the switch at the top.`r`nOtherwise, click on the box with the arrow inside next to each mod to go to the download page. You can hover over the mod's name in Automaton to see which specific file needs to be downloaded.`r`nAfter all of the mods have been downloaded, click on 'Install modpack.' After Automaton finishes installing the mods, close it to continue the install process.", "Ultimate Skyrim Install", [Windows.Forms.MessageBoxButtons]::OK, [Windows.Forms.MessageBoxIcon]::Information)
    Start-Process "$([AzurasStar]::installerSrc)\bin\automaton\Automaton.exe" -Wait
    $automatonSuccess = [Windows.Forms.MessageBox]::Show("Did Automaton complete? If it crashed, select no.", "Ultimate Skyrim Install", [Windows.Forms.MessageBoxButtons]::YesNo, [Windows.Forms.MessageBoxIcon]::Information)
    switch($automatonSuccess) {
        "Yes" {
            [Windows.Forms.MessageBox]::Show("You can now run the final steps", [AzurasStar]::Name, [Windows.Forms.MessageBoxButtons]::OK, [Windows.Forms.MessageBoxIcon]::Information)
            $startFinalize.Enabled = $true
        } "No" {
            [Windows.Forms.MessageBox]::Show("Restart Automaton and try again. If it crashes continuously, seek support in the Discord or on Reddit.", "Ultimate Skyrim Install", [Windows.Forms.MessageBoxButtons]::OK, [Windows.Forms.MessageBoxIcon]::Information)
        }
    }
})
$configForm.Controls.Add($startAutomaton)


$startFinalize = New-Object System.Windows.Forms.Button
$startFinalize.Enabled = $false
$startFinalize.Text = "Finalize Installation"
$startFinalize.Top = $AzurasStar.calculateNextButtonTopOffset()
$startFinalize.Left = [AzurasStar]::RightColumn
$startFinalize.Size = New-Object System.Drawing.Size([AzurasStar]::ButtonWidth, [AzurasStar]::ButtonHeight)
$startFinalize.ADD_CLICK({

    $ENB.configureENB()

    $Skyrim.cleanDLC()

    if($folderName -like "*Gamepad*") {
        Remove-Item "$($Skyrim.installPath)\ControlMap_Custom.txt" -Force -ErrorAction Ignore
    }
    $WshShell = New-Object -comObject WScript.Shell
    $Shortcut = $WshShell.CreateShortcut("$env:USERPROFILE\Desktop\Ultimate Skyrim.lnk")
    $targetPath = "`"$($Skyrim.installPath)\US\$folderName\ModOrganizer.exe`""
    $Shortcut.Arguments = "-p `"$folderName`" `"moshortcut://:SKSE`""
    $Shortcut.TargetPath = $targetPath
    $shortcut.IconLocation = "$($Skyrim.installPath)\TESV.exe"
    $Shortcut.WindowStyle = 7
    $Shortcut.Save()
    $postCompletion = [Windows.Forms.MessageBox]::Show("Congratulations! Ultimate Skyrim is installed and a shortcut has been created on your desktop! Would you like to launch Ultimate Skyrim now?", "Ultimate Skyrim Install", [Windows.Forms.MessageBoxButtons]::YesNo, [Windows.Forms.MessageBoxIcon]::Exclamation)
    switch($postCompletion) {
        "Yes" {
            Start-Process "`"$($Skyrim.installPath)\US\$folderName\ModOrganizer.exe`"" -ArgumentList "-p `"$folderName`" `"moshortcut://:SKSE`""
            $configForm.Close()
        } "No" {
            $postCompletionNO = [Windows.Forms.MessageBox]::Show("Would you like to quit the installer?", "Ultimate Skyrim Install", [Windows.Forms.MessageBoxButtons]::YesNo, [Windows.Forms.MessageBoxIcon]::Exclamation)
            if($postCompletionNO -eq "Yes") {
                $configForm.Close()
            }
        }
    }
})
$configForm.Controls.Add($startFinalize)

$configForm.ShowDialog()
