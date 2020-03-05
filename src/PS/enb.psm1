Using module .\AzurasStar.psm1

class ENB {

    $MessageBox
    static $presets
    [string] $currentPreset

    ENB($messageBox) {

        $this.MessageBox = $messageBox


        [ENB]::presets = @(
        "low",
        "medium",
        "high"
        )
    }

    [string]
    setENBPreset($preset) {
        return $this.currentPreset = $preset
    }

    [int]
    getVRAM() {
        Start-Process "$([AzurasStar]::installerPath)\src\bin\gpuz.exe" -ArgumentList "-dump $([AzurasStar]::installerPath)\src\bin\gpuinfo.xml" -Wait
        [xml]$gpuInfo = Get-Content "$([AzurasStar]::installerPath)\src\bin\gpuinfo.xml"
        return $gpuInfo.gpuz_dump.card.memsize
    }

    [int]
    getRAM() {
        return (Get-WmiObject -class "Win32_PhysicalMemory" | Measure-Object -Property Capacity -Sum).Sum/1024/1024
    }

    [int]
    getVideoMemory($RAM, $VRAM) {
        return $RAM + $VRAM - 2048
    }

    [string]
    detectENBPreset($videoMemory) {
        $recommendedPreset = ""
        $recommendedPresetMessage = (Get-Culture).TextInfo
        if($videoMemory -le 10240) {
            $recommendedPreset = "low"
        } elseif ($videoMemory -lt 14336 -and $videoMemory -gt 10240) {
            $recommendedPreset = "medium"
        } else {
            $recommendedPreset = "high"
        }
        $dialogResult = $this.MessageBox::Show("Your recommended ENB preset is $($recommendedPresetMessage.ToTitleCase($recommendedPreset)). Is this correct?", [AzurasStar]::Name, "YesNo");
        if($dialogResult -eq "Yes") {
            return $this.setENBPreset($recommendedPreset)
        } else {
            return $this.setENBPreset($this.selectENBPreset())
        }
    }

    [string]
    selectENBPreset() {
        $enbPreset = ""

        $Form = New-Object System.Windows.Forms.Form
        $Form.Icon = [AzurasStar]::Icon
        $Form.Text = "Select ENB preset"
        $Form.AutoSize = $true

        $DropDownLabel = new-object System.Windows.Forms.Label
        $DropDownLabel.AutoSize = $true;
        $DropDownLabel.Text = "Select the correct enb preset"

        $DropDown = new-object System.Windows.Forms.ComboBox
        ForEach($enb in [ENB]::presets) {
            [void] $DropDown.Items.Add($enb)
        }
        $DropDown.DropDownStyle = "DropDownList"
        $DropDown.SelectedItem = $DropDown.Items[0]
        $DropDown.Size = new-object System.Drawing.Size(GetDropDownWidth($DropDown), 10)

        $Button = new-object System.Windows.Forms.Button
        $Button.Text = "Select"
        $Button.Add_Click({
            Set-Variable -scope 1 -Name "enbPreset" -Value $DropDown.SelectedItem.ToString()
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

        return $enbPreset
    }
}
