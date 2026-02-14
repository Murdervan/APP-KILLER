#╔════════════════════════════════════════════════════════╗
#║                   Windows App Remover                  ║
#╠════════════════════════════════════════════════════════╣
#║  TYPE          ▸  Windows 10/11 Remove app tool        ║
#║  AUTHOR        ▸  Murdervan / AI                       ║
#║  NAMESPACE     ▸  https://github.com/Murdervan         ║
#║  LICENSE       ▸  MIT                                  ║
#║  VERSION       ▸  2.0                                ║
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

# Admin check
$IsAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $IsAdmin) {
    Write-Host "Administrator privileges required!" -ForegroundColor Red
    Read-Host "Press ENTER to exit"
    exit
}

# Logging setup
$ScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Definition
$TimeStamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$LogFile = Join-Path $ScriptRoot "AppRemoval_Log_$TimeStamp.txt"

function Write-Log {
    param($Level, $Message)
    $log = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') [$Level] $Message"
    Write-Output $log | Out-File -FilePath $LogFile -Append -Encoding UTF8
    Write-Host $log -ForegroundColor $(if($Level -eq "SUCCESS"){"Green"}elseif($Level -eq "WARNING"){"Yellow"}else{"White"})
}

Write-Log "INFO" "Script started - Windows $([System.Environment]::OSVersion.VersionString)"

# Robust AppX removal function
function Remove-AppxRobust {
    param([string[]]$Packages)
    
    foreach ($pkg in $Packages) {
        Write-Host "Removing: $pkg" -ForegroundColor Yellow
        
        # Remove installed packages (all users)
        Get-AppxPackage -AllUsers | Where-Object { $_.Name -like "*$pkg*" -or $_.PackageFullName -like "*$pkg*" } | 
            ForEach-Object { 
                try {
                    Remove-AppxPackage -Package $_.PackageFullName -AllUsers -ErrorAction Stop
                    Write-Log "SUCCESS" "$pkg (Installed)"
                }
                catch {
                    Write-Log "WARNING" "$pkg (Installed) - $($_.Exception.Message)"
                }
            }
        
        # Remove provisioned packages (new users)
        Get-AppxProvisionedPackage -Online | Where-Object { $_.DisplayName -like "*$pkg*" } | 
            ForEach-Object { 
                try {
                    Remove-AppxProvisionedPackage -Online -PackageName $_.PackageName -ErrorAction Stop
                    Write-Log "SUCCESS" "$pkg (Provisioned)"
                }
                catch {
                    Write-Log "WARNING" "$pkg (Provisioned) - $($_.Exception.Message)"
                }
            }
        
        # Win10 PowerShell 5 fallback
        if (Get-Command Get-AppxPackage -ErrorAction SilentlyContinue) {
            Get-AppxPackage * | Where-Object { $_.Name -like "*$pkg*" } | Remove-AppxPackage -ErrorAction SilentlyContinue
        }
    }
}

function Remove-OneDrive {
    Write-Host "Removing OneDrive" -ForegroundColor Yellow
    taskkill /f /im OneDrive.exe 2>$null
    & "$env:SystemRoot\SysWOW64\OneDriveSetup.exe" /uninstall -Wait 2>$null
    & "$env:SystemRoot\System32\OneDriveSetup.exe" /uninstall -Wait 2>$null
    Remove-Item "$env:USERPROFILE\OneDrive" -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item "$env:LOCALAPPDATA\Microsoft\OneDrive" -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item "$env:PROGRAMDATA\Microsoft OneDrive" -Recurse -Force -ErrorAction SilentlyContinue
    Write-Log "SUCCESS" "OneDrive fully removed"
}

function Remove-Edge {
    Write-Host "Removing Microsoft Edge" -ForegroundColor Yellow
    $edgePaths = @(
        "${env:ProgramFiles(x86)}\Microsoft\Edge\Application",
        "$env:LOCALAPPDATA\Microsoft\Edge"
    )
    foreach ($path in $edgePaths) {
        if (Test-Path $path) {
            Remove-Item $path -Recurse -Force -ErrorAction SilentlyContinue
        }
    }
    Remove-AppxRobust @("Microsoft.MicrosoftEdge", "Microsoft.MicrosoftEdge.Stable")
    Write-Log "SUCCESS" "Edge removed"
}

# Extended app list (40+ apps)
$apps = @{
    1  = @{ Name="Remove all apps (full debloat)"; Action="ALL" }
    2  = @{ Name="Copilot"; Package="Microsoft.Windows.Ai.Copilot.Provider" }
    3  = @{ Name="Dev Home"; Package="Microsoft.Windows.DevHome" }
    4  = @{ Name="Microsoft Family"; Package="MicrosoftCorporationII.MicrosoftFamily" }
    5  = @{ Name="Feedback Hub"; Package="Microsoft.WindowsFeedbackHub" }
    6  = @{ Name="Get Help"; Package="Microsoft.GetHelp" }
    7  = @{ Name="Camera"; Package="Microsoft.WindowsCamera" }
    8  = @{ Name="Calculator"; Package="Microsoft.WindowsCalculator" }
    9  = @{ Name="Voice Recorder"; Package="Microsoft.WindowsSoundRecorder" }
    10 = @{ Name="Media Player"; Package="Microsoft.WindowsMediaPlayer" }
    11 = @{ Name="Bing Apps"; Package="Microsoft.Bing*" }
    12 = @{ Name="Clipchamp"; Package="Clipchamp.Clipchamp" }
    13 = @{ Name="News"; Package="Microsoft.News" }
    14 = @{ Name="OneDrive"; Special="OneDrive" }
    15 = @{ Name="To Do"; Package="Microsoft.Todos" }
    16 = @{ Name="Outlook New"; Package="Microsoft.OutlookForWindows" }
    17 = @{ Name="Paint"; Package="Microsoft.Paint" }
    18 = @{ Name="Power Automate"; Package="Microsoft.PowerAutomateDesktop" }
    19 = @{ Name="Solitaire"; Package="Microsoft.MicrosoftSolitaireCollection" }
    20 = @{ Name="Sticky Notes"; Package="Microsoft.MicrosoftStickyNotes" }
    21 = @{ Name="YourPhone/Phone Link"; Package="Microsoft.YourPhone" }
    22 = @{ Name="Clock"; Package="Microsoft.WindowsAlarms" }
    23 = @{ Name="Weather"; Package="Microsoft.BingWeather" }
    24 = @{ Name="LinkedIn"; Package="Microsoft.LinkedIn" }
    25 = @{ Name="Music"; Package="Microsoft.ZuneMusic" }
    26 = @{ Name="Microsoft Store"; Package="Microsoft.WindowsStore" }
    27 = @{ Name="Microsoft Edge"; Special="Edge" }
    28 = @{ Name="Xbox"; Package="Microsoft.Xbox*" }
    29 = @{ Name="Teams"; Package="Microsoft.Teams" }
    30 = @{ Name="Skype"; Package="Microsoft.SkypeApp" }
    31 = @{ Name="Maps"; Package="Microsoft.WindowsMaps" }
    32 = @{ Name="Mail & Calendar"; Package="microsoft.windowscommunicationsapps" }
    33 = @{ Name="People"; Package="Microsoft.People" }
    34 = @{ Name="Movies & TV"; Package="Microsoft.ZuneVideo" }
    35 = @{ Name="Cortana"; Package="Microsoft.549981C3F5F10" }
    36 = @{ Name="Windows Web Experience"; Package="Microsoft.Windows.WebExperiencePack" }
    37 = @{ Name="Tips"; Package="Microsoft.Getstarted" }
    38 = @{ Name="3D Viewer"; Package="Microsoft.Microsoft3DViewer" }
    39 = @{ Name="Mixed Reality Portal"; Package="Microsoft.MixedReality.Portal" }
    40 = @{ Name="Print 3D"; Package="Microsoft.Print3D" }
    41 = @{ Name="Microsoft Edge WebView2"; Package="Microsoft Edge WebView" }
}

# Main menu loop
do {
    Clear-Host
    Write-Host "=== Windows 10/11 App Remover v2.1 ===" -ForegroundColor Green
    Write-Host "Log file: $LogFile" -ForegroundColor Gray
    Write-Host ""

    $keys = $apps.Keys | Sort-Object
    for ($i = 0; $i -lt $keys.Count; $i += 2) {
        $left = $keys[$i]
        $right = if ($i+1 -lt $keys.Count) { $keys[$i+1] } else { $null }
        
        $leftText = "{0,-3} {1}" -f "$left.", $apps[$left].Name
        $rightText = if ($right) { "{0,-3} {1}" -f "$right.", $apps[$right].Name } else { "" }
        
        Write-Host "$leftText $rightText"
    }

    Write-Host ""
    Write-Host "0. Exit" -ForegroundColor Red
    $choice = Read-Host "`nSelect (1-$($keys.Count))"

    if ($choice -eq "0") { break }

    if ($choice -eq "1") {
        # Remove all
        foreach ($app in $apps.Values | Where-Object { $_.Action -ne "ALL" }) {
            if ($app.Special -eq "OneDrive") { Remove-OneDrive }
            elseif ($app.Special -eq "Edge") { Remove-Edge }
            else { Remove-AppxRobust @($app.Package) }
        }
        Write-Host "`nAll apps removed!" -ForegroundColor Green
    }
    elseif ($apps.ContainsKey([int]$choice)) {
        $app = $apps[[int]$choice]
        if ($app.Special -eq "OneDrive") { Remove-OneDrive }
        elseif ($app.Special -eq "Edge") { Remove-Edge }
        else { Remove-AppxRobust @($app.Package) }
    }
    else {
        Write-Host "Invalid selection!" -ForegroundColor Red
    }
    
    Read-Host "`nPress ENTER for menu"
} while ($true)

Write-Log "INFO" "Script completed"
Write-Host "`nDone! Check log: $LogFile" -ForegroundColor Green

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


