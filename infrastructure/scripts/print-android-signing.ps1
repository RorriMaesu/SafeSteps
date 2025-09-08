param(
  [string]$JdkKeytool = '',
  [string]$AppDir = 'd:\boundariesApp\mobile\android\app',
  [string]$ReleaseKeystore = 'safesteps-release.keystore',
  [string]$ReleaseAlias = '',
  [string]$ReleaseStorePass = '',
  [string]$ReleaseKeyPass = ''
)

<# Resolve keytool path early #>
if (-not $JdkKeytool) {
  $candidates = @()
  if ($env:JAVA_HOME) {
    $candidates += Join-Path $env:JAVA_HOME 'bin\keytool.exe'
  }
  $candidates += @(
    'C:\Program Files\Java\jdk-17\bin\keytool.exe',
    'C:\Program Files\Eclipse Adoptium\jdk-17*\bin\keytool.exe',
    'C:\Program Files\Android\Android Studio\jbr\bin\keytool.exe'
  )
  $found = $null
  foreach ($cand in $candidates) {
    if ($cand -like '*\*') {
      $glob = Get-ChildItem -Path $cand -ErrorAction SilentlyContinue | Select-Object -First 1
      if ($glob) { $found = $glob.FullName; break }
    } elseif (Test-Path $cand) {
      $found = $cand; break
    }
  }
  if (-not $found) {
    $cmd = Get-Command keytool -ErrorAction SilentlyContinue
    if ($cmd) { $found = $cmd.Source }
  }
  if ($found) { $JdkKeytool = $found }
}
if (-not $JdkKeytool) { throw 'keytool not found. Install JDK 17 or set JAVA_HOME.' }

function Get-AndroidSha1 {
  param($Keystore, $Alias, $StorePass, $KeyPass, $Label)
  if (-not (Test-Path $Keystore)) { Write-Host "$( $Label ): keystore not found: $Keystore"; return }
  Write-Host "=== $( $Label ) ==="
  & $JdkKeytool -list -v -keystore $Keystore -alias $Alias -storepass $StorePass -keypass $KeyPass | Select-String 'SHA1:'
}

$debugKs = Join-Path $AppDir 'debug.keystore'
Get-AndroidSha1 -Keystore $debugKs -Alias 'androiddebugkey' -StorePass 'android' -KeyPass 'android' -Label 'Debug'

if ($ReleaseAlias -and $ReleaseStorePass -and $ReleaseKeyPass) {
  $releaseKs = Join-Path $AppDir $ReleaseKeystore
  Get-AndroidSha1 -Keystore $releaseKs -Alias $ReleaseAlias -StorePass $ReleaseStorePass -KeyPass $ReleaseKeyPass -Label 'Release'
} else {
  Write-Host 'Release: (provide alias/storepass/keypass params to print release SHA-1)'
}

