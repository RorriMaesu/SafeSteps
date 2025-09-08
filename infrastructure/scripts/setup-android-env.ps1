param(
  [string]$ProjectRoot = "$(Split-Path -Parent $PSScriptRoot)\..\mobile"
)

# Resolve project paths
$ProjectRoot = [System.IO.Path]::GetFullPath($ProjectRoot)
$AndroidDir = Join-Path $ProjectRoot 'android'
$LocalProps = Join-Path $AndroidDir 'local.properties'

Write-Host "Project: $ProjectRoot"
Write-Host "Android dir: $AndroidDir"

if (-not (Test-Path $AndroidDir)) {
  Write-Error "Android directory not found. Run: npx expo prebuild --platform android in $ProjectRoot"
  exit 1
}

# Detect Android SDK
$Sdk = $env:ANDROID_HOME
if (-not $Sdk -and $env:ANDROID_SDK_ROOT) { $Sdk = $env:ANDROID_SDK_ROOT }
if (-not $Sdk) {
  $Sdk = Join-Path $env:LOCALAPPDATA 'Android\Sdk'
}
if (-not (Test-Path $Sdk)) {
  Write-Warning "Android SDK not found at $Sdk. Install Android Studio and SDK Platform Tools."
} else {
  Write-Host "Detected ANDROID SDK at: $Sdk"
}

# Detect JDK 17
$Jdk = $env:JAVA_HOME
if (-not $Jdk -or -not (Test-Path (Join-Path $Jdk 'bin\java.exe'))) {
  $Candidates = @(
    'C:\Program Files\Eclipse Adoptium',
    'C:\Program Files\Microsoft\jdk-17',
    'C:\Program Files\Java'
  )
  foreach ($base in $Candidates) {
    if (Test-Path $base) {
      $found = Get-ChildItem $base -Recurse -Directory -ErrorAction SilentlyContinue | Where-Object { $_.Name -match 'jdk-17' }
      $jdkPath = $found | Select-Object -First 1 | ForEach-Object { $_.FullName }
      if ($jdkPath) { $Jdk = $jdkPath; break }
    }
  }
}
if ($Jdk -and (Test-Path (Join-Path $Jdk 'bin\java.exe'))) {
  Write-Host "Detected JAVA_HOME: $Jdk"
} else {
  Write-Warning "JDK 17 not found. Install Temurin/OpenJDK 17 and set JAVA_HOME."
}

# Write local.properties
if ($Sdk) {
  $content = @()
  $content += "sdk.dir=$($Sdk -replace '\\','\\\')"
  Set-Content -Path $LocalProps -Value ($content -join "`n") -Encoding ASCII
  Write-Host "Wrote $LocalProps"
} else {
  Write-Warning "Skipping local.properties write; SDK path unknown."
}

# Export for current session
if ($Jdk) { $env:JAVA_HOME = $Jdk }
if ($Sdk) { $env:ANDROID_HOME = $Sdk; $env:ANDROID_SDK_ROOT = $Sdk }

Write-Host "Done. You can now run: npx expo run:android" -ForegroundColor Green
