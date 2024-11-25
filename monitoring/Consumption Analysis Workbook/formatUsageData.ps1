# This script uses the csv version of Usage Dashboard Data file (CapacityUsage.csv) 
# This script produces a new file (rawContent.txt)


# ==============================
# Modify the header
# ==============================
$filePath = "CapacityUsage.csv"
$newFilePath = "CapacityUsageTemp.csv"
$csvText = Get-Content -Path $filePath
$newHeader = "TimeGenerated,UnitsUsed,InitiatedBy,SessionID,Category,Type,CopilotExperience,PluginsUsed"
$csvText[0] = $newHeader
$csvText | Set-Content -Path $newFilePath


# ==============================
# Modify the datetime format
# ==============================
$csvFilePath = "CapacityUsageTemp.csv"
$data = Import-Csv -Path $csvFilePath
foreach ($row in $data) {
    $row.TimeGenerated = [datetime]::ParseExact($row.TimeGenerated, "MMM dd, hh:mm tt", $null).ToString("yyyy-MM-ddTHH:mm:ssZ")
}
$data | Export-Csv -Path "CapacityUsageTempDate.csv" -NoTypeInformation


# ==============================
# Create rawContent.txt
# ==============================
$inputFile = "CapacityUsageTempDate.csv"
$outputFile = "rawContent.txt"
$csvContent = Get-Content -Path $inputFile
$header = $csvContent[0] -replace '"', ''
$dataLines = $csvContent[1..($csvContent.Length - 1)] | ForEach-Object {
    $_ -replace '"', '\"'
}
$modifiedContent = $header + "\r\n" + ($dataLines -join "\r\n")
Set-Content -Path $outputFile -Value $modifiedContent


# ==============================
# Clean temp files
# ==============================
Remove-Item "CapacityUsageTemp.csv"
Remove-Item "CapacityUsageTempDate.csv"