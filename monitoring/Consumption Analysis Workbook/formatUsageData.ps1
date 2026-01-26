# This script uses the csv version of Usage Dashboard Data file (CapacityUsage.csv) 
# This script produces a new file (rawContent.txt)

#Requires -Version 5.1
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# ==============================
# Configuration
# ==============================
$inputFilePath = "CapacityUsage.csv"
$outputFilePath = "rawContent.txt"
$tempDir = [System.IO.Path]::GetTempPath()
$tempFile1 = Join-Path $tempDir "CapacityUsageTemp_$(Get-Random).csv"
$tempFile2 = Join-Path $tempDir "CapacityUsageTempDate_$(Get-Random).csv"

# Validate input file exists
if (-not (Test-Path -Path $inputFilePath -PathType Leaf)) {
    Write-Error "Input file not found: $inputFilePath"
    exit 1
}

try {
    # ==============================
    # Modify the header
    # ==============================
    $csvText = Get-Content -Path $inputFilePath
    $newHeader = "TimeGenerated,UnitsUsed,InitiatedBy,SessionID,Category,Type,CopilotExperience,PluginsUsed"
    $csvText[0] = $newHeader
    $csvText | Set-Content -Path $tempFile1

    # ==============================
    # Modify the datetime format
    # ==============================
    $data = Import-Csv -Path $tempFile1
    foreach ($row in $data) {
        $row.TimeGenerated = [datetime]::ParseExact($row.TimeGenerated, "MMM dd, hh:mm tt", $null).ToString("yyyy-MM-ddTHH:mm:ssZ")
    }
    $data | Export-Csv -Path $tempFile2 -NoTypeInformation

    # ==============================
    # Create rawContent.txt
    # ==============================
    $csvContent = Get-Content -Path $tempFile2
    $header = $csvContent[0] -replace '"', ''
    $dataLines = $csvContent[1..($csvContent.Length - 1)] | ForEach-Object {
        $_ -replace '"', '\"'
    }
    $modifiedContent = $header + "\r\n" + ($dataLines -join "\r\n")
    Set-Content -Path $outputFilePath -Value $modifiedContent

    Write-Host "Successfully created: $outputFilePath" -ForegroundColor Green
}
finally {
    # ==============================
    # Clean temp files (always runs)
    # ==============================
    if (Test-Path $tempFile1) { Remove-Item $tempFile1 -ErrorAction SilentlyContinue }
    if (Test-Path $tempFile2) { Remove-Item $tempFile2 -ErrorAction SilentlyContinue }
}