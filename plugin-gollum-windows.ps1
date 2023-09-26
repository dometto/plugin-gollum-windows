$root = (Get-Item -Path $PSScriptRoot).PSDrive.Root
$LOGDIR  = Join-Path -Path $root -ChildPath '\rsc-logs\'
$LOGFILE = Join-Path -Path $LOGDIR -ChildPath 'gollum.log'
$INSTALLDIR = Join-Path -Path $root -ChildPath '\Program Files\gollum'
$BINDIR = Join-Path -Path $INSTALLDIR -ChildPath 'bin'
$GOLLUM_VERSION =  [Environment]::GetEnvironmentVariable('gollum_version')
$GOLLUM_WAR_URL = 'https://github.com/gollum/gollum/releases/{0}/download/gollum.war' -f $GOLLUM_VERSION
$BAT_FILE = '"C:\Program Files\Java\jre-1.8\bin\java.exe" -jar "C:\Program Files\gollum\gollum.war" -S gollum %*'

Function Write-Log([String] $logText) {
  '{0:u}: {1}' -f (Get-Date), $logText | Out-File $LOGFILE -Append
}

Function Main {

  try {
    New-Item -ItemType Directory -Path $LOGDIR -Force
    Write-Log "Log directory created."

  }
  catch {
    Write-Log "$_"
    Throw $_
  }

  Write-Log "Start plugin-windows-gollum"
  Write-Log "Gollum version parameter: {1}" -f $GOLLUM_VERSION

  try {
    New-Item -ItemType Directory -Path $INSTALLDIR
    New-Item -ItemType Directory -Path $BINDIR
    Write-Log "Installation directory created: {0}" -f $INSTALDIR 
  }
  catch {
      Write-Log "$_"
      Throw $_
  }

  try {
      Write-Log "Installing Java Runtime"
      choco feature enable -n allowGlobalConfirmation
      choco install javaruntime  --no-progress
  }
  catch {
      Write-Log "$_"
      Throw $_
  }

  Write-Log "Download Gollum WAR"
  try {
    Invoke-RestMethod $GOLLUM_WAR_URL -OutFile (Join-Path -Path $INSTALLDIR -ChildPath 'gollum.war')
    $BAT_FILE | Set-Content -Path (Join-Path -Path $BINDIR -ChildPath 'gollum.bat') 
  }
  catch {
      Write-Log "$_"
      Throw $_
  }
  $newpath = '{0}{1}{2}' -f $env:PATH,[IO.Path]::PathSeparator,$BINDIR
  $env:PATH = $newpath
  [Environment]::SetEnvironmentVariable($newpath, $env:PATH, [System.EnvironmentVariableTarget]::Machine)

}

Main