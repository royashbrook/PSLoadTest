#Requires -Version 7.2
Set-Location $PSScriptRoot

#helper
. .\helper.ps1

#start background process that does something in a loop and returns status
$bw = Start-Job -s { . .\main.ps1; main; }

# loop until break/esc
while (isNotBreak) { doProgressLoop $bw }

# cleanup background process
"cleaning up"
$bw | Stop-Job
$bw | Receive-Job
$bw | Remove-Job