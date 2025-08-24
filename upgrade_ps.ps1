Write-Host "Starting PowerShell 7.5 upgrade..."

# --- 1. Ensure Scoop is installed ---
if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
    Write-Host "Installing Scoop..."
    Invoke-Expression "& {$(Invoke-RestMethod https://get.scoop.sh)}"
} else {
    Write-Host "Scoop already installed."
}

# --- 2. Install or update PowerShell 7.5 (USER install only) ---
Write-Host "Installing PowerShell 7.5 via Scoop (user install)..."
try {
    scoop install pwsh --no-cache
} catch {
    Write-Host "PowerShell already installed. Updating..."
    scoop update pwsh
}

# --- 3. Locate pwsh.exe ---
$PwshPathScoop  = "$env:USERPROFILE\scoop\apps\pwsh\current\pwsh.exe"
$PwshPathGlobal = "C:\Program Files\PowerShell\7\pwsh.exe"

if (Test-Path $PwshPathScoop) {
    $PwshPath = $PwshPathScoop
} elseif (Test-Path $PwshPathGlobal) {
    $PwshPath = $PwshPathGlobal
} else {
    Write-Host "ERROR: Could not find pwsh.exe after install. Check Scoop or PATH."
    pause
    exit 1
}

Write-Host "PowerShell 7 found at: $PwshPath"

# --- 4. Update Windows Terminal default profile ---
$settingsPath = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
if (Test-Path $settingsPath) {
    try {
        $json = Get-Content $settingsPath -Raw | ConvertFrom-Json
        $pwshProfile = $json.profiles.list | Where-Object { $_.commandline -like "*pwsh.exe" }

        if ($pwshProfile) {
            $json.defaultProfile = $pwshProfile.guid
            $json | ConvertTo-Json -Depth 10 | Set-Content $settingsPath -Encoding UTF8
            Write-Host "Windows Terminal default set to PowerShell 7"
        } else {
            Write-Host "WARNING: Could not find pwsh profile in Windows Terminal settings."
        }
    } catch {
        Write-Host "WARNING: Failed to edit Terminal settings.json"
    }
}

# --- 5. Restart into PS7 in-place ---
Write-Host "Restarting this session into PowerShell 7..."
& $PwshPath -NoExit -Command "Write-Host 'PowerShell 7.5 is now active!'"
exit
