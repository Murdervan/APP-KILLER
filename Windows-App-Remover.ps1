# APP KILLER
# v2.1
# github.com/murdervan

# APP KILLER MATRIX LOADING
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Sæt konsol til fuld skærm, grøn på sort
$Host.UI.RawUI.WindowTitle = "APP KILLER v2.1 - MURDERVAN"
mode con cols=200 lines=100
$Host.UI.RawUI.BackgroundColor = "Black"
$Host.UI.RawUI.ForegroundColor = "Green"
Clear-Host

function Show-MatrixRain {
    $width = $Host.UI.RawUI.WindowSize.Width
    $height = $Host.UI.RawUI.WindowSize.Height
    $drops = @()

    # Initialiser drops
    0..($width-1) | ForEach-Object {
        $drops += @{
            x = $_
            y = Get-Random -Max $height
            speed = (Get-Random -Min 1 -Max 3)
            chars = @()
        }
    }

    # Fyld baggrund med sort første gang
    $blackLine = " " * $width
    0..($height-1) | ForEach-Object { Write-Host $blackLine -NoNewline; Write-Host "`r`n" -NoNewline }

    # Animation loop
    for ($i = 0; $i -lt 3; $i++) {
        $screen = @()
        0..($height-1) | ForEach-Object { $screen += (" " * $width) }

        foreach ($drop in $drops) {
            if ($drop.y -ge $height) { 
                $drop.y = 0
                $drop.chars = @()
            }

            # 0 eller 1
            $char = if ((Get-Random -Max 2) -eq 0) { "0" } else { "1" }
            $drop.chars += $char
            if ($drop.chars.Count -gt 15) { $drop.chars = $drop.chars[-14..-1] }

            for ($j = 0; $j -lt $drop.chars.Count; $j++) {
                $row = $drop.y - $j
                if ($row -ge 0 -and $row -lt $height) {
                    $col = [Math]::Min($drop.x, $width-1)
                    $screen[$row] = $screen[$row].Substring(0, $col) +
                                     ($drop.chars[$j] + $screen[$row].Substring($col + 1))
                }
            }

            $drop.y += $drop.speed
        }

        # Skriv hele skærmen
        Clear-Host
        foreach ($line in $screen) { Write-Host $line -NoNewline; Write-Host "`r`n" -NoNewline }

        Start-Sleep -Milliseconds 3
    }

    # Clear baggrund efter animation
    Clear-Host
}

# Kør Matrix-animationen
Show-MatrixRain
Write-Host "`nMATRIX INITIALIZED" -ForegroundColor Green


# ADMIN CHECK - HACKER STYLE
$IsAdmin = ([Security.Principal.WindowsPrincipal]`
    [Security.Principal.WindowsIdentity]::GetCurrent()
).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $IsAdmin) {
    Clear-Host
    Write-Host ''
    Write-Host '          ACCESS DENIED - ROOT REQUIRED' -ForegroundColor Red -BackgroundColor Black
    Write-Host '                 RUN AS ADMINISTRATOR' -ForegroundColor Yellow
    Write-Host ''
    Read-Host 'PRESS ENTER TO TERMINATE'
    exit
}

# SYSTEM RECON
$OSBuild = (Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion').CurrentBuild
$DisplayVersion = (Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion').DisplayVersion
$OSVersion = if ([int]$OSBuild -ge 22000) { '11' } else { '10' }

# HACKER LOG SYSTEM
$ScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Definition
if (-not $ScriptRoot) { $ScriptRoot = (Get-Location) }

# Lav unik log-fil
$TimeStamp = Get-Date -Format 'yyyy-MM-dd_HH-mm-ss'
$LogFile = Join-Path $ScriptRoot "AppKiller_LOG_$TimeStamp.txt"

# Opret filen hvis den ikke allerede findes
if (-not (Test-Path $LogFile)) {
    New-Item -Path $LogFile -ItemType File -Force | Out-Null
}

# Skriv til log
function Write-Log {
    param([string]$Msg)
    $time = Get-Date -Format 'HH:mm:ss'
    $entry = "[$time] $Msg"

    # Sørg for filen eksisterer inden skriv
    if (-not (Test-Path $LogFile)) { New-Item -Path $LogFile -ItemType File -Force | Out-Null }

    Add-Content -Path $LogFile -Value $entry
}

# NUCLEAR APP DELETION ENGINE (UNCHANGED)
function Remove-App {
    param($Name, $Package)

    Write-Host "  [>>] TARGET: $Name" -ForegroundColor Yellow
    $removed = $false

    $installed = Get-AppxPackage -AllUsers
    $provisioned = Get-AppxProvisionedPackage -Online

    foreach ($app in $installed | Where-Object {
        $_.Name -like "*$Package*" -or
        $_.PackageFamilyName -like "*$Package*" -or
        $_.PackageFullName -like "*$Package*"
    }) {
        try {
            Remove-AppxPackage -Package $app.PackageFullName -AllUsers -ErrorAction Stop
            $removed = $true
        } catch {}
    }

    foreach ($app in $provisioned | Where-Object {
        $_.DisplayName -like "*$Package*" -or
        $_.PackageName -like "*$Package*"
    }) {
        try {
            Remove-AppxProvisionedPackage -Online -PackageName $app.PackageName -ErrorAction Stop
            $removed = $true
        } catch {}
    }

    if ($removed) {
        Write-Log "TERMINATED: $Name"
        Write-Host "      [KILLED]" -ForegroundColor Green
    } else {
        Write-Log "NOT FOUND: $Name"
        Write-Host "      [GHOST]" -ForegroundColor DarkGray
    }
}

function Force-Remove-SpecialApps {

    Write-Host "`n[!!] FORCING REMOVAL: OneDrive + Xbox" -ForegroundColor Red

    # ===== ONEDRIVE =====
    Write-Host "  [>>] FORCE KILL: OneDrive" -ForegroundColor Yellow

    # Stop process
    Get-Process OneDrive -ErrorAction SilentlyContinue | Stop-Process -Force

    # Uninstall (system)
    $oneDriveSystem = "$env:SystemRoot\SysWOW64\OneDriveSetup.exe"
    $oneDriveSystem32 = "$env:SystemRoot\System32\OneDriveSetup.exe"

    if (Test-Path $oneDriveSystem) {
        Start-Process $oneDriveSystem "/uninstall" -NoNewWindow -Wait
    }

    if (Test-Path $oneDriveSystem32) {
        Start-Process $oneDriveSystem32 "/uninstall" -NoNewWindow -Wait
    }

    # Remove leftovers
    Remove-Item "$env:LOCALAPPDATA\Microsoft\OneDrive" -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item "$env:PROGRAMDATA\Microsoft OneDrive" -Recurse -Force -ErrorAction SilentlyContinue

    Write-Log "FORCE REMOVED: OneDrive"
    Write-Host "      [NUKED]" -ForegroundColor Green


    # ===== XBOX =====
    Write-Host "  [>>] FORCE KILL: Xbox" -ForegroundColor Yellow

    $xboxPackages = @(
        "Microsoft.GamingApp",
        "Microsoft.XboxApp",
        "Microsoft.XboxGamingOverlay",
        "Microsoft.XboxIdentityProvider",
        "Microsoft.XboxSpeechToTextOverlay",
        "Microsoft.Xbox.TCUI"
    )

    foreach ($pkg in $xboxPackages) {

        Get-AppxPackage -AllUsers *$pkg* | ForEach-Object {
            try {
                Remove-AppxPackage -Package $_.PackageFullName -AllUsers -ErrorAction Stop
                Write-Log "FORCE REMOVED: $pkg"
            } catch {}
        }

        Get-AppxProvisionedPackage -Online | Where-Object {
            $_.DisplayName -like "*$pkg*"
        } | ForEach-Object {
            try {
                Remove-AppxProvisionedPackage -Online -PackageName $_.PackageName -ErrorAction Stop
            } catch {}
        }
    }

    Write-Host "      [NUKED]" -ForegroundColor Green
}

# TARGET DATABASE (UNCHANGED)
$Categories = @{
    "SYSTEM" = @(
        @{N='Calculator'; P='Calculator'}
        @{N='Paint'; P='Paint'}
        @{N='Clock'; P='WindowsAlarms'}
        @{N='Windows Store'; P='WindowsStore'}
        @{N='Store Core'; P='Store'}
        @{N='OneDrive'; P='OneDrive'}
        @{N='Quick Assist'; P='QuickAssist'}
    )
    "MEDIA" = @(
        @{N='Media Player'; P='MediaPlayer'}
        @{N='Music'; P='ZuneMusic'}
        @{N='Camera'; P='WindowsCamera'}
        @{N='Voice Recorder'; P='SoundRecorder'}
        @{N='Photos'; P='Photos'}
        @{N='Clipchamp'; P='Clipchamp'}
    )
    "XBOX" = @(
        @{N='Xbox App'; P='XboxApp'}
        @{N='Xbox Game Bar'; P='XboxGamingOverlay'}
        @{N='Xbox Identity Provider'; P='XboxIdentityProvider'}
        @{N='Xbox Speech To Text'; P='XboxSpeechToTextOverlay'}
        @{N='Xbox TCUI'; P='Xbox.TCUI'}
    )
    "COMMUNICATION" = @(
        @{N='Teams Personal'; P='Teams'}
        @{N='Skype'; P='SkypeApp'}
        @{N='Mail & Calendar'; P='windowscommunicationsapps'}
        @{N='Outlook New'; P='OutlookForWindows'}
        @{N='LinkedIn'; P='LinkedIn'}
    )
    "PRODUCTIVITY" = @(
        @{N='To Do'; P='Todos'}
        @{N='Sticky Notes'; P='StickyNotes'}
        @{N='OneNote'; P='OneNote'}
        @{N='Office Hub'; P='MicrosoftOfficeHub'}
        @{N='Dev Home'; P='DevHome'}
    )
    "BLOAT" = @(
        @{N='Copilot'; P='Copilot'}
        @{N='Cortana'; P='Cortana'}
        @{N='Feedback Hub'; P='FeedbackHub'}
        @{N='Get Started'; P='Getstarted'}
        @{N='News'; P='News'}
        @{N='Weather'; P='BingWeather'}
        @{N='Solitaire'; P='MicrosoftSolitaireCollection'}
    )
    "EDGE / WEB" = @(
        @{N='Edge WebView2'; P='WebView2'}
        @{N='Web Experience Pack'; P='WebExperience'}
        @{N='Bing Search'; P='Bing'}
    )
    "3D / LEGACY" = @(
        @{N='3D Viewer'; P='3DViewer'}
        @{N='Mixed Reality Portal'; P='HolographicFirstRun'}
        @{N='Print 3D'; P='Print3D'}
        @{N='Paint 3D'; P='MSPaint'}
    )
    "EXTENSIONS" = @(
        @{N='HEIF Image Extensions'; P='HEIFImageExtension'}
        @{N='Web Media Extensions'; P='WebMediaExtensions'}
        @{N='Raw Image Extension'; P='RawImageExtension'}
    )
    "OTHER" = @(
        @{N='Phone Link'; P='YourPhone'}
        @{N='Family Safety'; P='MicrosoftFamily'}
        @{N='Store Ads'; P='StorePurchaseApp'}
    )
}

# PERFECT ASCII HACKER MENU - PURE STANDARD CHARACTERS
function Show-Menu {
    Clear-Host
    Write-Host '+===============================================================+' -ForegroundColor Green
    Write-Host '|                       APP KILLER v2.1                         |' -ForegroundColor Green
    Write-Host '|===============================================================|' -ForegroundColor Green
    Write-Host '| [1] SINGLE TARGET STRIKE         [REMOVE ONE APP]             |' -ForegroundColor Cyan
    Write-Host '| [2] NUCLEAR APP ANNIHILATION     [WIPE ALL APPS]              |' -ForegroundColor Cyan
    Write-Host '| [3] ACCESS KILL LOG              [VIEW LOG]                   |' -ForegroundColor Cyan
    Write-Host '| [4] WIPE FORENSICS               [CLEAN LOG]                  |' -ForegroundColor Cyan
    Write-Host '| [5] SYSTEM RECON SCAN            [SCAN LIVE]                  |' -ForegroundColor Cyan
    Write-Host '| [Q] TERMINATE SESSION            [EXIT HACK]                  |' -ForegroundColor Red
    Write-Host '|===============================================================|' -ForegroundColor Green
    Write-Host '|                      GITHUB/MURDERVAN                         |' -ForegroundColor Green
    Write-Host '+===============================================================+' -ForegroundColor Green
    Write-Host ''
}

# MAIN HACKER LOOP (UNCHANGED)
while ($true) {
    Show-Menu
    $choice = Read-Host ' ENTER COMMAND > '

    switch ($choice) {

        '1' {
            Clear-Host
            $indexMap = @{}
            $counter = 1
            foreach ($cat in $Categories.Keys) {
                Write-Host "`n=== $cat TARGETS ===" -ForegroundColor Cyan
                foreach ($app in $Categories[$cat]) {
                    Write-Host "  [$counter] $($app.N)"
                    $indexMap[$counter] = $app
                    $counter++
                }
            }
            $sel = Read-Host "`nTARGET NUMBER > "
            if ($indexMap.ContainsKey([int]$sel)) {
                $app = $indexMap[[int]$sel]
                Remove-App $app.N $app.P
            }
            Write-Host "`nSTRIKE COMPLETE" -ForegroundColor Green
            Read-Host 'PRESS ENTER'
        }

        '2' {
            Clear-Host
            Write-Host ''
            Write-Host '          NUCLEAR PROTOCOL ACTIVATED' -ForegroundColor Red -BackgroundColor Black
            Write-Host ''
            $conf = Read-Host 'ENTER "NUKE" TO KILL/REMOVE ALL APPS > '
            if ($conf -eq 'NUKE') {
                Write-Host 'DEPLOYING NUCLEAR STRIKE...' -ForegroundColor Red
                foreach ($cat in $Categories.Keys) {
                    foreach ($app in $Categories[$cat]) {
                        Remove-App $app.N $app.P
                        Start-Sleep -Milliseconds 200
                    }
                }

Force-Remove-SpecialApps

                Write-Host "`nSYSTEM CLEANSED" -ForegroundColor Green
                Read-Host 'PRESS ENTER'
            }
        }

        '3' {
            Clear-Host
            Write-Host 'KILL LOG' -ForegroundColor Yellow
            Write-Host '-------' -ForegroundColor Yellow
            if (Test-Path $LogFile) {
                Get-Content $LogFile
            } else { 
                Write-Host 'NO KILLS RECORDED YET' -ForegroundColor Yellow 
            }
            Read-Host 'PRESS ENTER'
        }

        '4' {
            if (Test-Path $LogFile) { 
                Clear-Content $LogFile 
                Write-Host 'FORENSICS WIPED' -ForegroundColor Red
            } else {
                Write-Host 'NO LOG TO WIPE' -ForegroundColor Yellow
            }
            Start-Sleep 1
        }

        '5' {
            Clear-Host
            Write-Host 'RUNNING SYSTEM RECON...' -ForegroundColor Cyan
            $installed = Get-AppxPackage -AllUsers
            $ok = 0
            $xx = 0
            foreach ($cat in $Categories.Keys) {
                Write-Host "`n=== $cat SCAN ===" -ForegroundColor Cyan
                foreach ($app in $Categories[$cat]) {
                    $found = $installed | Where-Object {
                        $_.Name -like "*$($app.P)*" -or
                        $_.PackageFamilyName -like "*$($app.P)*" -or
                        $_.PackageFullName -like "*$($app.P)*"
                    }
                    if ($found) {
                        Write-Host "  [LIVE] $($app.N)" -ForegroundColor Red
                        $ok++
                    } else {
                        Write-Host "  [DEAD] $($app.N)" -ForegroundColor Green
                        $xx++
                    }
                }
            }
            Write-Host "`nLIVE TARGETS  : $ok" -ForegroundColor Red
            Write-Host "TERMINATED    : $xx" -ForegroundColor Green
            Read-Host 'PRESS ENTER'
        }

        'Q' { 
            Clear-Host
            Write-Host 'SESSION TERMINATED' -ForegroundColor Red
            Start-Sleep 1
            Stop-Process -Id $PID 
        }
        'q' { 
            Clear-Host
            Write-Host 'SESSION TERMINATED' -ForegroundColor Red
            Start-Sleep 1
            Stop-Process -Id $PID 
        }
    }
}
