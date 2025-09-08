param(
  [switch]$Quiet
)

function Write-Info($msg) { if (-not $Quiet) { Write-Host $msg -ForegroundColor Cyan } }
function Write-Warn($msg) { Write-Host $msg -ForegroundColor Yellow }

$ErrorActionPreference = 'Stop'

# Detect Android SDK
$Sdk = $env:ANDROID_HOME
if (-not $Sdk -or -not (Test-Path $Sdk)) { $Sdk = $env:ANDROID_SDK_ROOT }
if (-not $Sdk -or -not (Test-Path $Sdk)) { $Sdk = Join-Path $env:LOCALAPPDATA 'Android\Sdk' }
if (-not (Test-Path $Sdk)) {
  Write-Warn "Android SDK not found. Install Android Studio and ensure SDK is at %LOCALAPPDATA%\Android\Sdk or set ANDROID_HOME."
} else {
  Write-Info "Detected Android SDK: $Sdk"
}

# Detect JDK 17
${jdkRoots} = @(
  (Join-Path $env:ProgramFiles 'Eclipse Adoptium'),
  (Join-Path $env:ProgramFiles 'Java'),
  (Join-Path $env:ProgramFiles 'Microsoft')
)
$Jdk = $null
foreach ($root in ${jdkRoots}) {
  if (-not (Test-Path $root)) { continue }
  $found = Get-ChildItem -Path $root -Directory -Recurse -ErrorAction SilentlyContinue |
    Where-Object { $_.Name -like 'jdk-17*' -and (Test-Path (Join-Path $_.FullName 'bin\java.exe')) } |
    Select-Object -First 1
  if ($found) { $Jdk = $found.FullName; break }
}
if (-not $Jdk) {
  Write-Warn "JDK 17 not found. Install Temurin/OpenJDK 17 and set JAVA_HOME."
} else {
  Write-Info "Detected JDK 17: $Jdk"
  $env:JAVA_HOME = $Jdk
}

# Write local.properties
$projectDir = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$androidDir = Join-Path $projectDir 'android'
if (-not (Test-Path $androidDir)) {
  Write-Info 'Android folder not found. Running expo prebuild...'
  Push-Location $projectDir
  npx expo prebuild --platform android --non-interactive | Out-Null
  Pop-Location
}

$localProps = Join-Path $androidDir 'local.properties'
if ($Sdk -and (Test-Path $androidDir)) {
  $sdkForward = ($Sdk -replace '\\','/')
  "sdk.dir=$sdkForward" | Out-File -FilePath $localProps -Encoding ASCII
  Write-Info "Wrote $localProps"
} else {
  Write-Warn 'Skipped writing local.properties (SDK or android folder missing).'
}

Write-Info 'Done.'
