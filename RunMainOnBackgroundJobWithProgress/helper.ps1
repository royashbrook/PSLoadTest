function isNotBreak() {
  #break on esc key
  if (!$Host.UI.RawUI.KeyAvailable) {
    $true
  }
  else {
    $key = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyUp,IncludeKeyDown")
    $key.VirtualKeyCode -ne 27
  }
}
function doProgressLoop($bw){
  $res = 0
  $bwres = $bw | receive-job
  if($bwres.length -ne 0){$res = $bwres[0]}
  $param = @{
    Activity = "Background Activity!".PadRight(25)
    Status = "Status Pct: $res%"
    PercentComplete = $res
  }
  if ($res -ne 0){Write-Progress @param}
  Start-Sleep -m 100
}