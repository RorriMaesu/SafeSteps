param(
  [string]$AdbPath = 'C:\Android\sdk\platform-tools\adb.exe',
  [string]$PackageName = 'com.safesteps.app',
  [int]$TimeoutSec = 300,
  [string]$TargetSerial,
  [switch]$AllAuthorized
)

Write-Host "Using ADB: $AdbPath"
if (-not (Test-Path $AdbPath)) {
  Write-Error "adb not found at $AdbPath"
  exit 1
}

$apkRelease = 'd:\boundariesApp\mobile\android\app\build\outputs\apk\release\app-release.apk'
$apkDebug   = 'd:\boundariesApp\mobile\android\app\build\outputs\apk\debug\app-debug.apk'
$apk = if (Test-Path $apkRelease) { $apkRelease } elseif (Test-Path $apkDebug) { $apkDebug } else { $null }
if (-not $apk) {
  Write-Error "APK not found. Build the app first."
  exit 1
}
Write-Host "APK: $apk"

& $AdbPath start-server | Out-Null

function Get-DevicesByState {
  $out = & $AdbPath devices
  $lines = $out -split "`n" | ForEach-Object { $_.Trim() } | Where-Object { $_ -and ($_ -notmatch '^List of devices attached') }
  $authorized = @()
  $unauthorized = @()
  foreach ($line in $lines) {
    $parts = $line -split "\s+"
    if ($parts.Length -ge 2) {
      $serial = $parts[0]
      $state  = $parts[1]
      if ($state -eq 'device') { $authorized += $serial }
      elseif ($state -eq 'unauthorized') { $unauthorized += $serial }
    }
  }
  return @{ authorized = $authorized; unauthorized = $unauthorized }
}

$sw = [System.Diagnostics.Stopwatch]::StartNew()
while ($sw.Elapsed.TotalSeconds -lt $TimeoutSec) {
  $devs = Get-DevicesByState
  if ($devs.unauthorized.Count -gt 0) {
    Write-Host "Device is connected but unauthorized. Please unlock the phone and tap 'Allow' on the USB debugging prompt.'"
  }
  if ($devs.authorized.Count -gt 0) { break }
  Write-Host "Waiting for device... (USB debugging enabled? USB mode: File Transfer/MTP?)"
  Start-Sleep -Seconds 3
}

if ($TargetSerial) {
  $targets = @($TargetSerial)
} elseif ($AllAuthorized) {
  $targets = @((Get-DevicesByState).authorized)
} else {
  $targets = @((Get-DevicesByState).authorized | Select-Object -First 1)
}

if (-not $targets -or $targets.Count -eq 0) {
  Write-Error "No authorized device detected within timeout."
  exit 1
}

foreach ($serial in $targets) {
  Write-Host "Installing to device: $serial"
  Write-Host "Uninstalling previous package (if any)..."
  & $AdbPath -s $serial uninstall $PackageName | Out-Null

  Write-Host "Installing APK..."
  $install = & $AdbPath -s $serial install -r $apk
  Write-Host $install
  $installSucceeded = ($install -match '(?i)Success') -or ($LASTEXITCODE -eq 0)
  if (-not $installSucceeded) {
    Write-Error "APK install may have failed on $serial. Output: $install"
    continue
  }

  Write-Host "Launching app on $serial..."
  & $AdbPath -s $serial shell monkey -p $PackageName -c android.intent.category.LAUNCHER 1 | Out-Null
  Write-Host "Done. App launched on $serial."
}
