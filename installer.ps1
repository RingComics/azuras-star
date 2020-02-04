Using module .\src\PS\AzurasStar.psm1
Using module .\src\PS\Skyrim.psm1

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.IO.Compression.FileSystem #Zip Compression

# Add helpers
Import-Module .\src\PS\PSUtils.psm1

$azurasStar = New-Object -TypeName AzurasStar

$skyrim = [Skyrim]::new([Windows.Forms.MessageBox])
$skyrim.setInstallationPath()

#Check prerequisites
#Is 64-Bit Java installed?
if(Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | Where-Object DisplayName -like "Java*") {
    if(Test-Path "$env:ProgramFiles\Java") {
        $javaInstalled = $true
    } else {
        $javaInstalled = $false
        [Windows.Forms.MessageBox]::Show("Java 32-bit is installed, but not Java 64-Bit. Please click 'Install Java' to install it and then restart the program.", "Ultimate Skyrim Install", [Windows.Forms.MessageBoxButtons]::OK, [Windows.Forms.MessageBoxIcon]::Error)
    }
} else {
    $javaInstalled = $false
}

#Is 7-Zip installed?
if(Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | Where-Object DisplayName -like "7-Zip*") {
    $7ZipInstalled = $true
} else {
    $7ZipInstalled = $false
}

#Configure and install prereqs
#Root Form window
$configForm = New-Object System.Windows.Forms.Form
$configForm.Width = 820
$configForm.Height = 665
$configForm.Text = "Azura's Star"
$configForm.MaximizeBox = $false
$configForm.MinimizeBox = $false
$configForm.FormBorderStyle = 'Fixed3D'
$configForm.Icon = [AzurasStar]::Icon

$configFormOutput = New-Object System.Windows.Forms.RichTextBox
$configFormOutput.Top = 100
$configFormOutput.Left = 10
$configFormOutput.Size = New-Object System.Drawing.Size(300, 500)
$configFormOutput.ReadOnly = $true
$configForm.Controls.Add($configFormOutput)

function output($text) {
    $configFormOutput.AppendText("$text `r`n")
    $configFormOutput.ScrollToCaret()
}

$configFormPreReqsLabel = New-Object System.Windows.Forms.Label
$configFormPreReqsLabel.Text = "Prerequisites"
$configFormPreReqsLabel.Top = "10"
$configFormPreReqsLabel.Left = "10"
$configFormPreReqsLabel.Anchor + "Left,Top"
$configForm.Controls.Add($configFormPreReqsLabel)

$configFormPreReqsJava = New-Object System.Windows.Forms.Button
switch($javaInstalled) {
    $true{
        $configFormPreReqsJava.Text = "Java Installed"
        $configFormPreReqsJava.Enabled = $false
        output("Java already installed")
    }
    $false{
        $configFormPreReqsJava.Text = "Install Java"
    }
}
$configFormPreReqsJava.Top = 35
$configFormPreReqsJava.Left = 10
$configFormPreReqsJava.Size = New-Object System.Drawing.Size(100, 25)
$configFormPreReqsJava.ADD_CLICK({
    Start-Process "$([AzurasStar]::installerSrc)\bin\jre-8u231-windows-x64.exe"
    output("Installing Java")
})
$configForm.Controls.Add($configFormPreReqsJava)

$configFormPreReqs7zip = New-Object System.Windows.Forms.Button
switch($7zipInstalled) {

    $true {
        $configFormPreReqs7zip.Text = "7zip Installed"
        $configFormPreReqs7zip.Enabled = $false
        output("7-Zip already Installed")
    }
    $false {
        $configFormPreReqs7zip.Text = "Install 7-Zip"
    }
}
$configFormPreReqs7zip.Top = 35
$configFormPreReqs7zip.Left = 110
$configFormPreReqs7zip.Size = New-Object System.Drawing.Size(100, 25)
$configFormPreReqs7zip.ADD_CLICK({
    Start-Process "$([AzurasStar]::installerSrc)\bin\7z1900-x64.exe"
    output("Installing 7-Zip")
})
$configForm.Controls.Add($configFormPreReqs7zip)

$configFormPreReqsSkyrim = New-Object System.Windows.Forms.Button
$configFormPreReqsSkyrim.Text = "Run Skyrim once"
$configFormPreReqsSkyrim.Top = 35
$configFormPreReqsSkyrim.Left = 210
$configFormPreReqsSkyrim.Size = New-Object System.Drawing.Size(100, 25)
$configFormPreReqsSkyrim.ADD_CLICK({
    [Windows.Forms.MessageBox]::Show("When Skyrim launches, let it automatically detect your settings, then launch to the main menu. Then you can exit Skyrim and come back here to run the Preinstall.", "Ultimate Skyrim Install", [Windows.Forms.MessageBoxButtons]::OK, [Windows.Forms.MessageBoxIcon]::Information)
    output("Launching Skyrim for first time set up")
    $steamPath = (Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | Where-Object DisplayName -Like "Steam" | Select-Object -ExpandProperty UninstallString) -replace "uninstall.exe", "steam.exe"
    $configFormPreReqsSkyrim.Enabled = $false
    Start-Process $steamPath -ArgumentList "-applaunch 72850" -Wait
    Start-Sleep -Seconds 5
    Wait-Process -Name SkyrimLauncher -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 5
    Wait-Process -Name TESV -ErrorAction SilentlyContinue
    if($javaInstalled -and $7ZipInstalled) {
        $configFormPreReqsPreinstall.Enabled = $true
        output("You may now run the Preinstall")

    } else {
        [Windows.Forms.MessageBox]::Show("Java and 7-Zip must be installed before you can run the Preinstall. Please install them and restart the installer", "Ultimate Skyrim Install", [Windows.Forms.MessageBoxButtons]::OK, [Windows.Forms.MessageBoxIcon]::Error)
        output("Java and 7-Zip must be installed before you can run the Preinstall. Please install them and restart the installer")
    }
})
$configForm.Controls.Add($configFormPreReqsSkyrim)

$configFormPreReqsPreinstall = New-Object System.Windows.Forms.Button
$configFormPreReqsPreinstall.Enabled = $false
$configFormPreReqsPreinstall.Text = "Run Preinstall"
$configFormPreReqsPreinstall.Top = 65
$configFormPreReqsPreinstall.Left = 210
$configFormPreReqsPreinstall.Size = New-Object System.Drawing.Size(100, 25)
$configFormPreReqsPreinstall.ADD_CLICK({

    output("Getting Nexus API key")
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
        $configFormGetAPIKey.Close()
    })
    $configFormGetAPIKey.Controls.Add($confirmAPIKey)
    $configFormGetAPIKey.ShowDialog()

    output("Copying ENB files...")
    Copy-Item -Path "$([AzurasStar]::installerSrc)\bin\d3d9.dll" -Destination $skyrim.installPath -Force
    Copy-Item -Path "$([AzurasStar]::installerSrc)\bin\enbhost.exe" -Destination $skyrim.installPath -Force
    Copy-Item -Path "$([AzurasStar]::installerSrc)\bin\enblocal.ini" -Destination $skyrim.installPath -Force
    output("Copied ENB files")

    output("Creating install directories")
    New-Item -ItemType Directory -Path "$($skyrim.installPath)\US" -Force
    New-Item -ItemType Directory -Path "$($skyrim.installPath)\US\Utilities" -Force
    New-Item -ItemType Directory -Path "$($skyrim.installPath)\US\Downloads" -Force

    foreach($file in (Get-ChildItem -Path "$([AzurasStar]::installerSrc)\ultsky")) {
        Copy-Item -Path $file.FullName -Destination "$($skyrim.installPath)\US\Downloads" -Force
    }
    Copy-Item -Path "$([AzurasStar]::installerSrc)\bin\US 406hf2 Gamepad - LD Hotfix 1.auto" -Destination "$($skyrim.installPath)\US" -Force
    Copy-Item -Path "$([AzurasStar]::installerSrc)\bin\US 406hf2 Keyboard - LD Hotfix 1.auto" -Destination "$($skyrim.installPath)\US" -Force

    output("Starting manual downloads, this might take a few minutes. This sometimes causes the window to not respond even though it's still working. Be patient :)")

    if(!(Test-Path "$([AzurasStar]::installerDownloads)\skse_1_07_03.7z")) {
        output("Downloading SKSE...")
        Invoke-WebRequest -Uri "https://skse.silverlock.org/beta/skse_1_07_03.7z" -OutFile "$([AzurasStar]::installerDownloads)\SKSE_install.7z"
        output("Downloaded SKSE")
    } else {
        output("SKSE already downloaded")
    }

    if(!(Test-Path "$([AzurasStar]::installerDownloads)\SKSEPreloader.zip")) {
        output("Downloading SKSE preloader...")
        $preloaderDownloadLink = Invoke-RestMethod -Uri "https://api.nexusmods.com/v1/games/skyrim/mods/75795/files/1000207412/download_link.json" -Headers @{"apikey" = "$apiKey"}
        Invoke-WebRequest -Uri $preloaderDownloadLink[0].URI -OutFile "$([AzurasStar]::installerDownloads)\SKSEPreloader.zip"
        output("Downloaded SKSE prelopader")
    } else {
        output("SKSE prelaoder already downloaded")
    }

    if(!(Test-Path "$($skyrim.installPath)\skse_loader.exe")) {
        output("Installing SKSE...")
        & "$env:ProgramFiles\7-Zip\7z.exe" "x" "`"$([AzurasStar]::installerDownloads)\SKSE_install.7z`"" "-o`"$([AzurasStar]::installerDownloads)`"" > $null
        Get-ChildItem -Path "$([AzurasStar]::installerDownloads)\skse_1_07_03" | Copy-Item -Destination $skyrim.installPath -Recurse -Container -Force
        output("Installed SKSE")
    } else {
        output("SKSE already installed")
    }

    if(!(Test-Path "$($skyrim.installPath)\d3dx9_42.dll")) {
        output("Installing SKSE preloader...")
        $SKSEzip = Get-Item "$([AzurasStar]::installerDownloads)\SKSEPreloader.zip"
        [System.IO.Compression.ZipFile]::ExtractToDirectory($SKSEzip.FullName, $skyrim.installPath)
        output("Installed SKSE preloader")
    } else {
        output("SKSE already installed")
    }

    if(!(Test-Path -Path "$([AzurasStar]::installerDownloads)\TES5Edit.7z")) {
        output("Downloading TES5Edit...")
        $TES5EditDownloadLink = Invoke-RestMethod -Uri "https://api.nexusmods.com/v1/games/skyrim/mods/25859/files/1000309592/download_link.json" -Headers @{"apikey" = "$apiKey"}
        Invoke-WebRequest -Uri $TES5EditDownloadLink[0].URI -OutFile "$([AzurasStar]::installerDownloads)\TES5Edit.7z"
        output("Downloaded TES5Edit")
    } else {
        output("TES5Edit already downloaded")
    }

    if(!(Test-Path -Path "$($skyrim.installPath)\US\Utilities\TES5Edit.exe")) {
        output("Extracting TES5Edit...")
        & "$env:ProgramFiles\7-Zip\7z.exe" "x" "$([AzurasStar]::installerDownloads)/TES5Edit.7z" "-o$($skyrim.installPath)\US\Utilities" > $null
        Remove-Item "$([AzurasStar]::installerDownloads)\TES5Edit.7z"
        output("Extracted TES5Edit")
    } else {
        output("TES5Edit already installed")
    }

    if(!(Test-Path "$($skyrim.installPath)\US\Downloads\NVAC - New Vegas Anti Crash-53635-7-5-1-0.zip")) {
        output("Downloading NVAC...")
        $NVACDownloadLink = Invoke-RestMethod -Uri "https://api.nexusmods.com/v1/games/newvegas/mods/53635/files/1000039152/download_link.json" -Headers @{"apikey" = "$apiKey"}
        Invoke-WebRequest -Uri $NVACDownloadLink[0].URI -OutFile "$($skyrim.installPath)\US\Downloads\NVAC - New Vegas Anti Crash-53635-7-5-1-0.zip"
        output("Downloaded NVAC")
    } else {
        output("NVAC already downloaded")
    }

    if(!(Test-Path "$($skyrim.installPath)\US\Downloads\Wyrmstooth 1.17B.zip")) {
        output("Downloading Wyrmstooth...")
        Invoke-WebRequest -Uri "https://archive.org/download/Wyrmstooth1.17B/Wyrmstooth%201.17B.zip" -OutFile "$($skyrim.installPath)\US\Downloads\Wyrmstooth 1.17B.zip"
        output("Downloaded Wyrmstooth")
    } else {
        output("Wyrmstooth already downloaded")
    }

    output("Getting VideoMemory")
    Start-Process "$([AzurasStar]::installerPath)\src\bin\gpuz.exe" -ArgumentList "-dump $([AzurasStar]::installerPath)\src\bin\gpuinfo.xml" -Wait
    [xml]$gpuInfo = Get-Content "$([AzurasStar]::installerPath)\src\bin\gpuinfo.xml"
    $VRAM = $gpuInfo.gpuz_dump.card.memsize
    $RAM = (Get-WmiObject -class "Win32_PhysicalMemory" | Measure-Object -Property Capacity -Sum).Sum/1024/1024
    $videoMem = "Video Memory: " + (($RAM + $VRAM) - 2048) + " MB"
    $configFormVideoMemory.Text = $videoMem
    if($videoMem -le 10240) {
        $recSpec = "Low"; $PresetIndex = 0
    }
    if($videoMem -lt 14336 -and $videoMem -gt 10240) {
        $recSpec = "Medium"; $PresetIndex = 1
    }
    if($videoMem -ge 14336) {
        $recSpec = "High"; $PresetIndex = 2
    }
    [Windows.Forms.MessageBox]::Show("Your recommended ENB preset is $recSpec.", "Ultimate Skyrim Install", [Windows.Forms.MessageBoxButtons]::OK, [Windows.Forms.MessageBoxIcon]::Information)
    output("Setting ENB preset")
    $configFormENBPreset.SelectedIndex = $PresetIndex
    output("Setting VideoMemory in enblocal.ini")
    (Get-Content -Path "$([AzurasStar]::installerSrc)\bin\enblocal.ini" -raw) -replace "INSERTRAMHERE", (($RAM + $VRAM) - 2048) | Set-Content "$($skyrim.installPath)\enblocal.ini"
    if(!(Test-Path -Path "$($skyrim.installPath)\US\Downloads\US 4.0.6hf2 DynDOLOD.rar")) {
        [Windows.Forms.MessageBox]::Show("Due to the size of DynDOLOD, it must be downloaded manually. You will be directed to the download page. Please drag and drop the file into the downloads folder that will open when you hit OK", "Ultimate Skyrim Install", [Windows.Forms.MessageBoxButtons]::OK, [Windows.Forms.MessageBoxIcon]::Information)
        Start-Process "https://mega.nz/#!SANlQY7R!deorWwQBDDw4GoHYfJ-7NJVOWQ1U-KsoH1HrdG4PFaI"
        Start-Process "$($skyrim.installPath)\US\Downloads"
        output("Downloading DynDOLOD")
        while(!(Test-Path -Path "$($skyrim.installPath)\US\Downloads\US 4.0.6hf2 DynDOLOD.rar")) {
        }
        [Windows.Forms.MessageBox]::Show("Now you can run Automaton!", "Ultimate Skyrim Install", [Windows.Forms.MessageBoxButtons]::OK, [Windows.Forms.MessageBoxIcon]::Information)
    } else {
        output("DynDOLOD already downloaded")
    }
    output("Ready to run Automaton! Double check your settings and rerun Preinstall if you need to change something")
    $startAutomaton.Enabled = $true
})
$configForm.Controls.Add($configFormPreReqsPreinstall)

$configFormENBPreset = New-Object System.Windows.Forms.ComboBox
$configFormENBPreset.Top = 35
$configFormENBPreset.Left = 320
$configFormENBPreset.Size = New-Object System.Drawing.Size(100, 25)
$configFormENBPreset.Items.Add("Low")
$configFormENBPreset.Items.Add("Medium")
$configFormENBPreset.Items.Add("High")
$configForm.Controls.Add($configFormENBPreset)

$configFormVideoMemory = New-Object System.Windows.Forms.Label
$configFormVideoMemory.Text = "Video Memory: "
$configFormVideoMemory.Top = 60
$configFormVideoMemory.Left = 320
$configFormVideoMemory.Size = New-Object System.Drawing.Size(150, 25)
$configForm.Controls.Add($configFormVideoMemory)

$configFormENBLabel = New-Object System.Windows.Forms.Label
$configFormENBLabel.Text = "ENB Preset"
$configFormENBLabel.Top = 10
$configFormENBLabel.Left = 320
$configForm.Controls.Add($configFormENBLabel)

$configFormInstallPathLabel = New-Object System.Windows.Forms.TextBox
$configFormInstallPathLabel.Text = "Install Path: $($skyrim.installPath)\US"
$configFormInstallPathLabel.Top = 100
$configFormInstallPathLabel.Left = 320
$configFormInstallPathLabel.Size = New-Object System.Drawing.Size(400, 25)
$configFormInstallPathLabel.ReadOnly = $true
$configForm.Controls.Add($configFormInstallPathLabel)

$configFormDownloadPathLabel = New-Object System.Windows.Forms.TextBox
$configFormDownloadPathLabel.Text = "Download Path: $($skyrim.installPath)\US\Downloads"
$configFormDownloadPathLabel.Top = 135
$configFormDownloadPathLabel.Left = 320
$configFormDownloadPathLabel.Size = New-Object System.Drawing.Size(400, 25)
$configFormDownloadPathLabel.ReadOnly = $true
$configForm.Controls.Add($configFormDownloadPathLabel)

$startAutomaton = New-Object System.Windows.Forms.Button
$startAutomaton.Enabled = $false
$startAutomaton.Text = "Run Automaton"
$startAutomaton.Top = 170
$startAutomaton.Left = 320
$startAutomaton.Size = New-Object System.Drawing.Size(400, 25)
$startAutomaton.ADD_CLICK({
    output("Running Automaton")
    [Windows.Forms.MessageBox]::Show("When Automaton launches, select either Keyboard or Gamepad from $($skyrim.installPath)\US and then copy the install and download paths into their respective fields.`r`nAllow Automaton to access your Nexus account and handle NXM links (required). If you are a Nexus premium member, Automaton can download each mod for you automatically by clicking on the switch at the top.`r`nOtherwise, click on the box with the arrow inside next to each mod to go to the download page. You can hover over the mod's name in Automaton to see which specific file needs to be downloaded.`r`nAfter all of the mods have been downloaded, click on 'Install modpack.' After Automaton finishes installing the mods, close it to continue the install process.", "Ultimate Skyrim Install", [Windows.Forms.MessageBoxButtons]::OK, [Windows.Forms.MessageBoxIcon]::Information)
    Start-Process "$([AzurasStar]::installerSrc)\bin\automaton\Automaton.exe" -Wait
    $automatonSuccess = [Windows.Forms.MessageBox]::Show("Did Automaton complete? If it crashed, select no.", "Ultimate Skyrim Install", [Windows.Forms.MessageBoxButtons]::YesNo, [Windows.Forms.MessageBoxIcon]::Information)
    switch($automatonSuccess) {
        "Yes" {
            output("Configuring ENB")
            $folderName = (Get-ChildItem -Path "$($skyrim.installPath)\US" | Where-Object Name -like "US*" | Where-Object Attributes -eq "Directory").Name -replace "\\", ""
            $configFormENBPreset.Enabled = $false
            Copy-Item -Path "$([AzurasStar]::installerSrc)\ini\$($configFormENBPreset.SelectedIndex)\Skyrim.ini" -Destination "$($skyrim.installPath)\US\$folderName\profiles\$folderName\Skyrim.ini" -Force
            Copy-Item -Path "$([AzurasStar]::installerSrc)\ini\$($configFormENBPreset.SelectedIndex)\SkyrimPrefs.ini" -Destination "$($skyrim.installPath)\US\$folderName\profiles\$folderName\SkyrimPrefs.ini" -Force
            foreach($file in (Get-ChildItem "$([AzurasStar]::installerSrc)\ENB" -Recurse)) {
                Copy-Item -Path $file.FullName -Destination "$($skyrim.installPath)" -Force
            }
            Remove-Item -Path "$($skyrim.installPath)\US\$folderName\mods\Snowfall Weathers\ENB Files - empty into Skyrim Directory\enblocal.ini" -ErrorAction SilentlyContinue
            foreach($file in (Get-ChildItem "$($skyrim.installPath)\US\$folderName\mods\Snowfall Weathers\ENB Files - empty into Skyrim Directory")) {
                Copy-Item -Path $file.FullName -Destination "$($skyrim.installPath)" -Force -Recurse -Container
            }
            output("Starting ModOrganizer to create ini")
            [Windows.Forms.MessageBox]::Show("ModOrganizer will launch and then close. Do not touch your mouse or keyboard. Click ok to any pop-ups", "Ultimate Skyrim Install", [Windows.Forms.MessageBoxButtons]::OK, [Windows.Forms.MessageBoxIcon]::Information)
            Start-Process "$($skyrim.installPath)\US\$folderName\ModOrganizer.exe"
            Start-Sleep -Seconds 5
            Stop-Process -Name ModOrganizer
            $modOrganizerIni = (Get-Content -Path "$($skyrim.installPath)\US\$folderName\ModOrganizer.ini")
            foreach($line in $modOrganizerIni) {
                if($line -like "size=*") {
                    $temp = [int]($line -replace "size=", "")
                    if($temp -gt 0) {
                        $numberOfEXE = $temp
                    }
                }
            }
            $DLCList = "Update", "Dawnguard", "Dragonborn", "Hearthfires"
            $newEXEs = ""
            $i = $numberOfEXE + 1
            $DLCPATH = $skyrim.installPath -replace '\\', "/"
            foreach($DLC in $DLCList) {
                $newEXEs = $newEXEs + "$i\title=Clean $DLC`r`n$i\toolbar=false`r`n$i\ownicon=true`r`n$i\binary=$DLCPATH/US/Utilities/TES5Edit.exe`r`n$i\arguments=`"-autoexit -quickautoclean -autoload $DLC.esm`"`r`n$i\workingDirectory=`r`n$i\steamAppID=`r`n"
                $i++
            }
            $newEXEs = $newEXEs + "size=$($i - 1)"
            (Get-Content -Path "$($skyrim.installPath)\US\$folderName\ModOrganizer.ini" -Raw) -replace "size=$numberOfEXE", $newEXEs | Set-Content -Path "$($skyrim.installPath)\US\$folderName\ModOrganizer.ini"
            (Get-Content -Path "$($skyrim.installPath)\US\$folderName\ModOrganizer.ini" -Raw) + "[Settings]`r`nlanguage=en`r`noverwritingLooseFilesColor=@Variant(\0\0\0\x43\x1@@\xff\xff\0\0\0\0\0\0)`r`noverwrittenLooseFilesColor=@Variant(\0\0\0\x43\x1@@\0\0\xff\xff\0\0\0\0)`r`noverwritingArchiveFilesColor=@Variant(\0\0\0\x43\x1@@\xff\xff\0\0\xff\xff\0\0)`r`noverwrittenArchiveFilesColor=@Variant(\0\0\0\x43\x1@@\0\0\xff\xff\xff\xff\0\0)`r`ncontainsPluginColor=@Variant(\0\0\0\x43\x1@@\0\0\0\0\xff\xff\0\0)`r`ncontainedColor=@Variant(\0\0\0\x43\x1@@\0\0\0\0\xff\xff\0\0)`r`ncompact_downloads=false`r`nmeta_downloads=false`r`nuse_prereleases=false`r`ncolorSeparatorScrollbars=true`r`nlog_level=1`r`ncrash_dumps_type=1`r`ncrash_dumps_max=5`r`noffline_mode=false`r`nuse_proxy=false`r`nendorsement_integration=true`r`nhide_api_counter=false`r`nload_mechanism=0`r`nhide_unchecked_plugins=false`r`nforce_enable_core_files=true`r`ndisplay_foreign=true`r`nlock_gui=false`r`narchive_parsing_experimental=false" | Set-Content -Path "$($skyrim.installPath)\US\$folderName\ModOrganizer.ini"
            $cleanDLCButton.Enabled = $true
            [Windows.Forms.MessageBox]::Show("You can now clean your DLCs", [AzurasStar]::Name, [Windows.Forms.MessageBoxButtons]::OK, [Windows.Forms.MessageBoxIcon]::Information)
        } "No" {
            [Windows.Forms.MessageBox]::Show("Restart Automaton and try again. If it crashes continuously, seek support in the Discord or on Reddit.", "Ultimate Skyrim Install", [Windows.Forms.MessageBoxButtons]::OK, [Windows.Forms.MessageBoxIcon]::Information)
        }
    }
})
$configForm.Controls.Add($startAutomaton)

$cleanDLCButton = New-Object System.Windows.Forms.Button
$cleanDLCButton.Enabled = $false
$cleanDLCButton.Text = "Clean DLCs"
$cleanDLCButton.Top = 200
$cleanDLCButton.Left = 320
$cleanDLCButton.Size = New-Object System.Drawing.Size(400, 25)
$cleanDLCButton.ADD_CLICK({
    $folderName = (Get-ChildItem -Path "$($skyrim.installPath)\US" | Where-Object Name -like "US*" | Where-Object Attributes -eq "Directory").Name -replace "\\", ""
    [Windows.Forms.MessageBox]::Show("Dismiss developer pop-ups if they come up and are preventing TES5Edit from running. Consider supporting the TES5Edit project!", [AzurasStar]::Name, [Windows.Forms.MessageBoxButtons]::OK, [Windows.Forms.MessageBoxIcon]::Information)
    foreach($dlc in [Skyrim]::DLC) {
        output("Cleaning $dlc.esm")
        $cleaning = Start-Process "$($skyrim.installPath)\US\$folderName\ModOrganizer.exe" -ArgumentList "-p `"$folderName`" `"moshortcut://:Clean $dlc`"" -PassThru
        Wait-Process -Id $cleaning.Id
        Wait-Process TES5Edit
    }
    $cleanDLCButton.Enabled = $false
    $startFinalize.Enabled = $true
    [Windows.Forms.MessageBox]::Show("All DLCs have been cleaned", [AzurasStar]::Name, [Windows.Forms.MessageBoxButtons]::OK, [Windows.Forms.MessageBoxIcon]::Information)
})
$configForm.Controls.Add($cleanDLCButton)


$startFinalize = New-Object System.Windows.Forms.Button
$startFinalize.Enabled = $false
$startFinalize.Text = "Finalize Installation"
$startFinalize.Top = 320
$startFinalize.Left = 320
$startFinalize.Size = New-Object System.Drawing.Size(400, 25)
$startFinalize.ADD_CLICK({
    if($folderName -like "*Gamepad*") {
        Remove-Item "$($skyrim.installPath)\ControlMap_Custom.txt" -Force
    }
    $WshShell = New-Object -comObject WScript.Shell
    $Shortcut = $WshShell.CreateShortcut("$env:USERPROFILE\Desktop\Ultimate Skyrim.lnk")
    $targetPath = "`"$($skyrim.installPath)\US\$folderName\ModOrganizer.exe`""
    $Shortcut.Arguments = "-p `"$folderName`" `"moshortcut://:SKSE`""
    $Shortcut.TargetPath = $targetPath
    $shortcut.IconLocation = "$($skyrim.installPath)\TESV.exe"
    $Shortcut.WindowStyle = 7
    $Shortcut.Save()
    $postCompletion = [Windows.Forms.MessageBox]::Show("Congratulations! Ultimate Skyrim is installed and a shortcut has been created on your desktop! Would you like to launch Ultimate Skyrim now?", "Ultimate Skyrim Install", [Windows.Forms.MessageBoxButtons]::YesNo, [Windows.Forms.MessageBoxIcon]::Exclamation)
    switch($postCompletion) {
        "Yes" {
            Start-Process "`"$($skyrim.installPath)\US\$folderName\ModOrganizer.exe`"" -ArgumentList "-p `"$folderName`" `"moshortcut://:SKSE`""
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
