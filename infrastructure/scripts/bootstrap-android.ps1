param(
  [string]$ProjectRoot = "$(Split-Path -Parent $PSScriptRoot)\..\mobile",
  [switch]$AcceptAll
)
$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'

function Info($m){ Write-Host $m -ForegroundColor Cyan }
function Warn($m){ Write-Warning $m }
function Ok($m){ Write-Host $m -ForegroundColor Green }

$ProjectRoot = [IO.Path]::GetFullPath($ProjectRoot)
$AndroidDir = Join-Path $ProjectRoot 'android'
$LocalProps = Join-Path $AndroidDir 'local.properties'

Info "ProjectRoot: $ProjectRoot"

# 1) Ensure JDK 17
$JdkOk = $false
if ($env:JAVA_HOME -and (Test-Path (Join-Path $env:JAVA_HOME 'bin\java.exe'))) {
  $JdkOk = $true
  Info "Found JAVA_HOME at $env:JAVA_HOME"
} else {
  try {
    $javaVer = & java -version 2>&1
    if ($LASTEXITCODE -eq 0 -and ($javaVer -match 'version "17')) { $JdkOk = $true }
  } catch {}
}
if (-not $JdkOk) {
  Info 'Installing JDK 17 via winget (requires Windows 11 and winget).'
  try {
    winget install -e --id EclipseAdoptium.Temurin.17.JDK --silent --accept-source-agreements --accept-package-agreements
  } catch { Warn "winget install failed: $_" }
  # Detect after install
  $candidates = @('C:\Program Files\Eclipse Adoptium','C:\Program Files\Microsoft','C:\Program Files\Java')
  foreach ($base in $candidates) {
    if (Test-Path $base) {
      $found = Get-ChildItem $base -Recurse -Directory -ErrorAction SilentlyContinue | Where-Object { $_.Name -like 'jdk-17*' -and (Test-Path (Join-Path $_.FullName 'bin\java.exe')) } | Select-Object -First 1
      if ($found) { $env:JAVA_HOME = $found.FullName; break }
    }
  }
}
if (-not ($env:JAVA_HOME) -or -not (Test-Path (Join-Path $env:JAVA_HOME 'bin\java.exe'))) { throw 'JDK 17 not found. Please install JDK 17 and re-run.' }
Ok "JAVA_HOME=$env:JAVA_HOME"

# 2) Ensure Android SDK with cmdline-tools
if (-not $env:ANDROID_HOME) { $env:ANDROID_HOME = Join-Path $env:LOCALAPPDATA 'Android\Sdk' }
if (-not (Test-Path $env:ANDROID_HOME)) { New-Item -ItemType Directory -Force -Path $env:ANDROID_HOME | Out-Null }
$CmdlineDir = Join-Path $env:ANDROID_HOME 'cmdline-tools\latest'
$SdkMgrBat = Join-Path $CmdlineDir 'bin\sdkmanager.bat'
if (-not (Test-Path $SdkMgrBat)) {
  Info 'Installing Android cmdline-tools...'
  $zipUrl = 'https://dl.google.com/android/repository/commandlinetools-win-11076708_latest.zip'
  $tmp = Join-Path $env:TEMP 'cmdline-tools.zip'
  Invoke-WebRequest -Uri $zipUrl -OutFile $tmp
  $extractRoot = Join-Path $env:ANDROID_HOME 'cmdline-tools'
  $extract = Join-Path $extractRoot '_tmp'
  if (Test-Path $extract) { Remove-Item -Recurse -Force $extract }
  New-Item -ItemType Directory -Force -Path $extract | Out-Null
  Expand-Archive -Path $tmp -DestinationPath $extract -Force
  if (Test-Path $CmdlineDir) { Remove-Item -Recurse -Force $CmdlineDir }
  New-Item -ItemType Directory -Force -Path $CmdlineDir | Out-Null
  # Copy contents of extracted cmdline-tools into .../latest
  Copy-Item -Recurse -Force (Join-Path $extract 'cmdline-tools\*') -Destination $CmdlineDir
  Remove-Item $tmp -Force
  Remove-Item -Recurse -Force $extract
}
Ok "Android cmdline-tools ready at $CmdlineDir"

# 3) Install SDK packages and accept licenses (non-interactive)
$resp = Join-Path $env:TEMP 'sdk-yes.txt'
Set-Content -Path $resp -Value (('y' + "`r`n") * 200) -Encoding ASCII
$pkgList = @('platform-tools','platforms;android-34','build-tools;34.0.0')
Info ("Installing SDK packages: {0}" -f ($pkgList -join ', '))
foreach ($pkg in $pkgList) {
  Start-Process -FilePath $SdkMgrBat -ArgumentList @($pkg, "--sdk_root=$($env:ANDROID_HOME)") -NoNewWindow -Wait -RedirectStandardInput $resp | Out-Null
}
Info 'Accepting licenses'
Start-Process -FilePath $SdkMgrBat -ArgumentList @('--licenses', "--sdk_root=$($env:ANDROID_HOME)") -NoNewWindow -Wait -RedirectStandardInput $resp | Out-Null
Ok 'SDK packages installed and licenses accepted.'

# 4) Prebuild android if missing
if (-not (Test-Path $AndroidDir)) {
  Push-Location $ProjectRoot
  npx expo prebuild --platform android --non-interactive
  Pop-Location
}

# 5) Write local.properties
${sdkForward} = ($env:ANDROID_HOME -replace '\\','/')
"sdk.dir=$sdkForward" | Out-File -FilePath $LocalProps -Encoding ASCII
Ok "Wrote $LocalProps"

# 6) Build debug APK
Push-Location (Join-Path $ProjectRoot 'android')
./gradlew.bat :app:assembleDebug
$code = $LASTEXITCODE
Pop-Location
if ($code -ne 0) {
  throw "Gradle build failed with exit code $code"
}
Ok 'Build complete. APK is under mobile/android/app/build/outputs/apk/debug/'
