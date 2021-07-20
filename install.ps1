 param (
    [string]$installer_log,
    [switch]$run_from_godot = $false
 )
if(!$run_from_godot) {
    $installer_log = New-TemporaryFile
    Write-Host("Installer log: " + $installer_log)
    $exec = $PSCommandPath + " -run_from_godot -installer_log " + $installer_log
    Start-Process powershell.exe -Argument $exec -WindowStyle Hidden
    exit
}
Write-Host("Writing output to " + $installer_log)
Clear-Content $installer_log
"STATUS,10%" | Add-Content $installer_log
"STATUS,50%" | Add-Content $installer_log
"STATUS,100%" | Add-Content $installer_log
Write-Host("Done")
