#Requires -Version 7.2

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

#start background process that does something in a loop and returns status
$sb = { while ($true) { "{0:yyyy-MM-dd HH:mm:ss.fff} - I'm a background worker!" -f (get-date); sleep -m 500 } }
$bw = sajb -s $sb

# loop until break/esc
while (isNotBreak) { $bw | receive-job; sleep -m 100 } 

# cleanup background process
write-host "cleaning up"
$bw | stop-job
$bw | receive-job
$bw | remove-job