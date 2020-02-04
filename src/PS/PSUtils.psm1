# Find the size of the largest dropdown item
function GetDropDownWidth
{
    param($comboBox)
    $maxWidth = 0
    $width = 0
    ForEach ($item in $comboBox)
    {
        $width = [System.Windows.Forms.TextRenderer]::MeasureText($item.ToString(), $comboBox.Font).Width;
        if ($width -gt $maxWidth)
        {
            $maxWidth = $width;
        }
    }
    # Return the width plus a bit of padding for the arrow in the box
    return $maxWidth + 40
}
