#!/usr/bin/env pwsh
<#
  Auto YouTube Downloader Professional - PowerShell
  Version: 3.3.0 (PowerShell port)
  Requirements: yt-dlp, ffmpeg, curl, python3 (or python)
#>

set-StrictMode -Version Latest

$VERSION = '3.3.0'

# Determine home directory cross-platform
if ($env:USERPROFILE) { $HOME = $env:USERPROFILE } elseif ($env:HOME) { $HOME = $env:HOME } else { $HOME = [Environment]::GetFolderPath('UserProfile') }

$DOWNLOAD_DIR = Join-Path $HOME 'Downloads' 'YT_Downloads'
$CONFIG_FILE = Join-Path $HOME '.yt_downloader_config.json'
$LOG_FILE = Join-Path $DOWNLOAD_DIR 'logs' 'yt_downloader.log'
$TEMP_DIR = Join-Path ([System.IO.Path]::GetTempPath()) 'yt_downloader'
$MAX_RETRIES = 3

$REQUIRED_PACKAGES = @('yt-dlp','ffmpeg','curl')

# Data structures
$QualityMap = @{}
$QualityOptions = @('max','4k','2k','1080p','720p')
$VideoFormatOptions = @('mp4','mkv','webm')
$AudioFormatOptions = @('mp3','m4a','flac','wav')

function Initialize {
    Clear-Host
    Write-Host "Initializing Auto YouTube Downloader..." -ForegroundColor Cyan

    New-Item -ItemType Directory -Path (Join-Path $DOWNLOAD_DIR 'videos') -Force | Out-Null
    New-Item -ItemType Directory -Path (Join-Path $DOWNLOAD_DIR 'audio') -Force | Out-Null
    New-Item -ItemType Directory -Path (Join-Path $DOWNLOAD_DIR 'logs') -Force | Out-Null
    New-Item -ItemType Directory -Path $TEMP_DIR -Force | Out-Null

    Init-Maps
    Load-Config
    Check-Dependencies
}

function Init-Maps {
    $Script:QualityMap['max'] = 'bestvideo+bestaudio/best'
    $Script:QualityMap['4k'] = 'bestvideo[height<=2160]+bestaudio/best'
    $Script:QualityMap['2k'] = 'bestvideo[height<=1440]+bestaudio/best'
    $Script:QualityMap['1080p'] = 'bestvideo[height<=1080]+bestaudio/best'
    $Script:QualityMap['720p'] = 'bestvideo[height<=720]+bestaudio/best'
    $Script:QualityMap['audio_only'] = 'bestaudio/best'
}

function Load-Config {
    if (Test-Path $CONFIG_FILE) {
        try {
            $cfg = Get-Content $CONFIG_FILE -Raw | ConvertFrom-Json -ErrorAction Stop
            $Script:DEFAULT_QUALITY = $cfg.DEFAULT_QUALITY
            $Script:DEFAULT_FORMAT = $cfg.DEFAULT_FORMAT
            $Script:SAVE_HISTORY = $cfg.SAVE_HISTORY
            $Script:AUTO_UPDATE = $cfg.AUTO_UPDATE
        } catch {
            Write-Host "Failed to read config, using defaults." -ForegroundColor Yellow
            Set-DefaultConfig
        }
    } else {
        Set-DefaultConfig
    }
}

function Set-DefaultConfig {
    $Script:DEFAULT_QUALITY = '1080p'
    $Script:DEFAULT_FORMAT = 'mp4'
    $Script:SAVE_HISTORY = $true
    $Script:AUTO_UPDATE = $true
    Save-Config
}

function Save-Config {
    $obj = [PSCustomObject]@{
        DEFAULT_QUALITY = $Script:DEFAULT_QUALITY
        DEFAULT_FORMAT  = $Script:DEFAULT_FORMAT
        SAVE_HISTORY    = $Script:SAVE_HISTORY
        AUTO_UPDATE     = $Script:AUTO_UPDATE
    }
    $json = $obj | ConvertTo-Json -Depth 2
    $json | Set-Content -Path $CONFIG_FILE -Force
}

function Check-Dependencies {
    $missing = $false
    foreach ($pkg in $REQUIRED_PACKAGES) {
        if (-not (Get-Command $pkg -ErrorAction SilentlyContinue)) {
            Write-Host "[ERROR] Missing required package: $pkg" -ForegroundColor Red
            $missing = $true
        }
    }
    # Check python variants
    if (-not (Get-Command python3 -ErrorAction SilentlyContinue) -and -not (Get-Command python -ErrorAction SilentlyContinue)) {
        Write-Host "[ERROR] Missing required package: python3 or python" -ForegroundColor Red
        $missing = $true
    }

    if ($missing) {
        Write-Host ""; Write-Host "Install the missing packages using:" -ForegroundColor Yellow
        Write-Host "  Windows: choco install yt-dlp ffmpeg curl python" -ForegroundColor White
        Write-Host "  Ubuntu/Debian: sudo apt install yt-dlp ffmpeg curl python3" -ForegroundColor White
        Write-Host "  macOS: brew install yt-dlp ffmpeg curl python" -ForegroundColor White
        Exit 1
    }
}

function Show-Banner {
    Clear-Host
    Write-Host "Auto YouTube Downloader - PowerShell" -ForegroundColor Cyan
    Write-Host "Version: $VERSION" -ForegroundColor White
    Write-Host "Storage: $DOWNLOAD_DIR" -ForegroundColor Cyan
    Write-Host ""
}

function Pause-Screen {
    Write-Host ""; Read-Host -Prompt 'Press Enter to continue'
}

function Log-Message {
    param([string]$Message)
    $line = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') $Message"
    $line | Add-Content -Path $LOG_FILE
}

function Select-OptionFromList {
    param(
        [string[]]$Options,
        [string]$Prompt = 'Select an option'
    )
    for ($i=0; $i -lt $Options.Count; $i++) {
        $num = $i + 1
        Write-Host "[$num] $($Options[$i])"
    }
    while ($true) {
        $sel = Read-Host -Prompt $Prompt
        if ([int]::TryParse($sel,[ref]$null) -and $sel -ge 1 -and $sel -le $Options.Count) {
            return $Options[$sel-1]
        }
        Write-Host "Invalid selection." -ForegroundColor Yellow
    }
}

function Download-Media {
    param([string]$MediaType)

    Write-Host "--- $MediaType Download ---" -ForegroundColor Green
    $url = Read-Host -Prompt 'Enter the URL'
    if ([string]::IsNullOrWhiteSpace($url)) {
        Write-Host "No URL provided." -ForegroundColor Red
        Pause-Screen
        return
    }

    if ($MediaType -eq 'Video') {
        Write-Host "Select video quality:`n"
        $quality = Select-OptionFromList -Options $QualityOptions -Prompt 'Choose quality (number)'
        Write-Host "`nSelect video format:`n"
        $format = Select-OptionFromList -Options $VideoFormatOptions -Prompt 'Choose format (number)'
    } else {
        $quality = 'audio_only'
        Write-Host "Select audio format:`n"
        $format = Select-OptionFromList -Options $AudioFormatOptions -Prompt 'Choose format (number)'
    }

    Execute-Engine -Url $url -Quality $quality -Format $format -MediaType $MediaType
}

function Execute-Engine {
    param(
        [string]$Url,
        [string]$Quality,
        [string]$Format,
        [string]$MediaType
    )

    if ($MediaType -eq 'Video') { $output_subfolder = 'videos' } else { $output_subfolder = 'audio' }
    $retries = 0
    Write-Host "Starting download..." -ForegroundColor Yellow

    while ($retries -lt $MAX_RETRIES) {
        if ($MediaType -eq 'Video') {
            $args = @('-f', $QualityMap[$Quality], '--merge-output-format', $Format, '--no-mtime', '--add-metadata', '--embed-thumbnail', '--console-title', '-o', (Join-Path $DOWNLOAD_DIR $output_subfolder + '\%(title)s.%(ext)s'), $Url)
            try {
                & yt-dlp @args
            } catch {
                # ignore, handle via exit code
            }
        } else {
            $args = @('-x','--audio-format',$Format,'--audio-quality','0','--no-mtime','--add-metadata','--embed-thumbnail','--console-title','-o',(Join-Path $DOWNLOAD_DIR $output_subfolder + '\%(title)s.%(ext)s'),$Url)
            try { & yt-dlp @args } catch {}
        }

        if ($LASTEXITCODE -eq 0) {
            Write-Host "`nDownload completed successfully." -ForegroundColor Green
            Log-Message "$MediaType downloaded successfully: $Url"
            if ($SAVE_HISTORY) {
                "$((Get-Date).ToString('yyyy-MM-dd HH:mm:ss')) | $MediaType | $Url" | Add-Content -Path (Join-Path $DOWNLOAD_DIR 'history.log')
            }
            Pause-Screen
            return
        }

        $retries++
        Write-Host "Retrying download ($retries/$MAX_RETRIES)..." -ForegroundColor Yellow
        Start-Sleep -Seconds 2
    }

    Write-Host "`nDownload failed after $MAX_RETRIES attempts." -ForegroundColor Red
    Log-Message "Download failed: $Url"
    Pause-Screen
}

function Update-Engine {
    Write-Host "Updating yt-dlp..." -ForegroundColor Cyan
    try {
        & yt-dlp -U
        if ($LASTEXITCODE -eq 0) { Write-Host "yt-dlp updated successfully." -ForegroundColor Green } else { Write-Host "Failed to update yt-dlp." -ForegroundColor Red }
    } catch {
        Write-Host "Failed to update yt-dlp." -ForegroundColor Red
    }
    Pause-Screen
}

function View-History {
    $history_file = Join-Path $DOWNLOAD_DIR 'history.log'
    if (Test-Path $history_file) {
        Get-Content $history_file | Out-Host -Paging
    } else {
        Write-Host "No download history found." -ForegroundColor Yellow
        Pause-Screen
    }
}

function Main-Menu {
    while ($true) {
        Show-Banner
        Write-Host "1) Download Video"
        Write-Host "2) Download Audio"
        Write-Host "3) Update yt-dlp"
        Write-Host "4) View Download History"
        Write-Host "5) Exit`n"

        $choice = Read-Host -Prompt 'Select an option (number)'
        switch ($choice) {
            '1' { Download-Media -MediaType 'Video' }
            '2' { Download-Media -MediaType 'Audio' }
            '3' { Update-Engine }
            '4' { View-History }
            '5' { Write-Host 'Goodbye.' -ForegroundColor Green; Exit 0 }
            Default { Write-Host 'Invalid option.' -ForegroundColor Red; Start-Sleep -Seconds 1 }
        }
    }
}

# Entry point
Initialize
Main-Menu
