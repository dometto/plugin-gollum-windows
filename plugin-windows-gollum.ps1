$root = (Get-Item -Path $PSScriptRoot).PSDrive.Root
$LOGDIR  = Join-Path -Path $root -ChildPath '\rsc-logs\'
$LOGFILE = Join-Path -Path $LOGDIR -ChildPath 'gollum.log'
$INSTALLDIR = Join-Path -Path $root -ChildPath '\ProgramFiles\gollum'
$BINDIR = Join-Path -Path $INSTALLDIR -ChildPath 'bin'
$GOLLUM_WAR_URL = "https://github.com/gollum/gollum/releases/latest/download/gollum.war"
$GOLLUM_VERSION =  [Environment]::GetEnvironmentVariable('gollum_version')

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
    Write-Log "Installation directory created."
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