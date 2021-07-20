 param (
    [string]$installer_log,
    [switch]$run_from_godot = $false
 )
if(!$run_from_godot) {
    $installer_log = $PSScriptRoot + "\install.log"
    Write-Host($installer_log)
    $exec = $PSCommandPath + " -run_from_godot -installer_log " + $installer_log
    Start-Process powershell.exe -Argument $exec -WindowStyle Hidden
    exit
}
Write-Host("Writing output to " + $installer_log)
Clear-Content $installer_log
for ($i = 0 ; $i -le 100 ; $i++) {
    "PROGRESS," + $i | Add-Content $installer_log
    Start-Sleep -Milliseconds 100
    if($i -eq 20) {
        "INFO,Doing this" | Add-Content $installer_log
    } elseif($i -eq 50) {
        "INFO,Doing that" | Add-Content $installer_log
    } elseif($i -eq 90) {
        "INFO,Almost done" | Add-Content $installer_log
    }
}
Write-Host("Done")
