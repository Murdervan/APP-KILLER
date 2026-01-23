#╔════════════════════════════════════════════════════════╗
#║                   Windows App Remover                  ║
#╠════════════════════════════════════════════════════════╣
#║  TYPE          ▸  PowerShell Script                    ║
#║  AUTHOR        ▸  Murdervan / AI                       ║
#║  NAMESPACE     ▸  https://github.com/Murdervan         ║
#║  LICENSE       ▸  MIT                                  ║
#║  VERSION       ▸  1.2.0                                ║
#║  STATUS        ▸  Stable (Refurb Edition)              ║
#║  LAST UPDATE   ▸  2026-01-22                           ║
#║  REPOSITORY    ▸  https://github.com/Murdervan/Windows-app-remover
#╠════════════════════════════════════════════════════════╣
#║  DESCRIPTION   ▸                                       ║
#║                                                        ║
#║  Windows 10 & 11 built-in app removal tool designed    ║
#║  for fast PC refurbishment and deployment.             ║
#║                                                        ║
#║  Removes AppX and provisioned packages system-wide,    ║
#║  supports OneDrive full uninstall, logging, menu       ║
#║  selection and USB execution.                          ║
#║                                                        ║
#╚════════════════════════════════════════════════════════╝

# ---------------- ADMIN CHECK ----------------
$IsAdmin = ([Security.Principal.WindowsPrincipal] `
    [Security.Principal.WindowsIdentity]::GetCurrent() `
).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $IsAdmin) {
    Write-Host "Please run this script as Administrator." -ForegroundColor Red
    Write-Host "Press ENTER to exit..."
    Read-Host
    exit
}

# ---------------- LOGGING ----------------
$ScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Definition
$TimeStamp  = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$LogFile    = Join-Path $ScriptRoot "AppRemoval_Log_$TimeStamp.log"

function Write-Log {
    param ([string]$Level, [string]$Message)
    $time = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Add-Content -Path $LogFile -Value "[$time] $Level $Message"
}

# ---------------- FUNCTIONS ----------------
function Remove-App {
    param ([string]$Name, [string]$Package)

    $installed = Get-AppxPackage -AllUsers | Where-Object { $_.Name -like $Package }

    if ($installed) {
        Write-Host "Removing $Name..." -ForegroundColor Yellow
        try {
            Get-AppxPackage -AllUsers | Where-Object { $_.Name -like $Package } |
                Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue

            Get-AppxProvisionedPackage -Online | Where-Object { $_.DisplayName -like $Package } |
                Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue

            Write-Host "$Name removed successfully." -ForegroundColor Green
            Write-Log "SUCCESS" "AppX: $Name"
        }
        catch {
            Write-Host "Failed to remove $Name" -ForegroundColor Red
            Write-Log "FAILED" "AppX: $Name | $($_.Exception.Message)"
        }
    }
    else {
        Write-Host "$Name is already removed." -ForegroundColor Cyan
        Write-Log "INFO" "$Name already removed"
    }
}

function Remove-OneDrive {
    Write-Host "Removing OneDrive..." -ForegroundColor Yellow
    try {
        taskkill /f /im OneDrive.exe 2>$null

        if (Test-Path "$env:SystemRoot\SysWOW64\OneDriveSetup.exe") {
            Start-Process "$env:SystemRoot\SysWOW64\OneDriveSetup.exe" "/uninstall" -Wait
        }
        elseif (Test-Path "$env:SystemRoot\System32\OneDriveSetup.exe") {
            Start-Process "$env:SystemRoot\System32\OneDriveSetup.exe" "/uninstall" -Wait
        }

        Remove-Item "$env:USERPROFILE\OneDrive" -Recurse -Force -ErrorAction SilentlyContinue
        Remove-Item "$env:LOCALAPPDATA\Microsoft\OneDrive" -Recurse -Force -ErrorAction SilentlyContinue
        Remove-Item "$env:PROGRAMDATA\Microsoft OneDrive" -Recurse -Force -ErrorAction SilentlyContinue

        Write-Host "OneDrive removed successfully." -ForegroundColor Green
        Write-Log "SUCCESS" "OneDrive"
    }
    catch {
        Write-Host "Failed to remove OneDrive" -ForegroundColor Red
        Write-Log "FAILED" "OneDrive | $($_.Exception.Message)"
    }
}

# ---------------- APP LIST ----------------
$apps = @{
    1  = @{ Name="REMOVE ALL"; Action="ALL" }
    2  = @{ Name="Copilot";                  Package="Microsoft.Windows.Ai.Copilot.Provider" }
    3  = @{ Name="Dev Home";                 Package="Microsoft.Windows.DevHome" }
    4  = @{ Name="Microsoft Family";         Package="MicrosoftCorporationII.MicrosoftFamily" }
    5  = @{ Name="Feedback Hub";             Package="Microsoft.WindowsFeedbackHub" }
    6  = @{ Name="Get Help (System Locked)"; Package="Microsoft.GetHelp" }
    7  = @{ Name="Camera";                   Package="Microsoft.WindowsCamera" }
    8  = @{ Name="Calculator";               Package="Microsoft.WindowsCalculator" }
    9  = @{ Name="Voice Recorder";           Package="Microsoft.WindowsSoundRecorder" }
    10 = @{ Name="Media Player";             Package="Microsoft.WindowsMediaPlayer" }
    11 = @{ Name="Microsoft Bing Apps";      Package="Microsoft.Bing" }
    12 = @{ Name="Clipchamp";                Package="Clipchamp.Clipchamp" }
    13 = @{ Name="Microsoft News";           Package="Microsoft.News" }
    14 = @{ Name="OneDrive";                 Special="OneDrive" }
    15 = @{ Name="Microsoft To Do";          Package="Microsoft.Todos" }
    16 = @{ Name="Outlook (New)";            Package="Microsoft.OutlookForWindows" }
    17 = @{ Name="Paint";                    Package="Microsoft.Paint" }
    18 = @{ Name="Power Automate";           Package="Microsoft.PowerAutomateDesktop" }
    19 = @{ Name="Solitaire & Casual Games"; Package="Microsoft.MicrosoftSolitaireCollection" }
    20 = @{ Name="Sticky Notes";             Package="Microsoft.MicrosoftStickyNotes" }
    21 = @{ Name="Phone Link";               Package="Microsoft.YourPhone" }
    22 = @{ Name="Clock";                    Package="Microsoft.WindowsAlarms" }
    23 = @{ Name="Weather";                  Package="Microsoft.BingWeather" }
    24 = @{ Name="LinkedIn";                 Package="Microsoft.LinkedIn" }
    25 = @{ Name="Music App";                Package="Microsoft.ZuneMusic" }
}

# ---------------- MENU ----------------
do {
    Clear-Host
    Write-Host "=== WINDOWS BUILT-IN APP REMOVER ===" -ForegroundColor Cyan
    Write-Host "=== Author: Murdervan / github.com/murdervan ===" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "1. REMOVE ALL APPS" -ForegroundColor Red
    Write-Host ""

    $keys = $apps.Keys | Sort-Object
    $half = [Math]::Ceiling($keys.Count / 2)

    for ($i = 0; $i -lt $half; $i++) {
        $leftKey  = $keys[$i]
        $rightKey = if ($i + $half -lt $keys.Count) { $keys[$i + $half] } else { $null }

        $leftText  = "{0,-3} {1,-30}" -f "$leftKey.", $apps[$leftKey].Name
        $rightText = if ($rightKey) {
            "{0,-3} {1,-30}" -f "$rightKey.", $apps[$rightKey].Name
        } else { "" }

        Write-Host "$leftText $rightText"
    }

    Write-Host ""
    Write-Host "0. Exit"

    $choice = Read-Host "`nSelect an option"

    if ($choice -eq "0") {
        Write-Host "`nScript finished. You may now close this window." -ForegroundColor Yellow
        break
    }

    if ($choice -eq "1") {
        foreach ($app in $apps.Values | Where-Object { $_.Name -ne "REMOVE ALL" }) {
            if ($app.Special -eq "OneDrive") {
                Remove-OneDrive
            }
            else {
                Remove-App -Name $app.Name -Package $app.Package
            }
        }
        Pause
        continue
    }

    if ($apps.ContainsKey([int]$choice)) {
        $app = $apps[[int]$choice]
        if ($app.Special -eq "OneDrive") {
            Remove-OneDrive
        }
        else {
            Remove-App -Name $app.Name -Package $app.Package
        }
    }
    else {
        Write-Host "Invalid selection." -ForegroundColor Red
    }

    Pause
}
while ($true)
