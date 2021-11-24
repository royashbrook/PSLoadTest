param(
  [Parameter(Mandatory)][string]$serverURL = "http://localhost:8080", 
  [Parameter(Mandatory)][ValidateRange(1,30)][int]$targetRPS = 30, 
  [Parameter(Mandatory)][string]$authKey = "testvalue"
)

#init and welcome
$start = get-date
$logfile = "{0:yyyyMMddHHmmss}.csv" -f $start
"id,res,ms" > $logfile
"Hit ESC to stop spinning up threads. Program will spin down sensibly."
"Output will be saved to $logfile."
$currentRPS = 1
$totalRequests = 0

#scriptblock with test
$sb = {
  param([string]$serverURL, [string]$authKey, [int]$requests_sent)

  #params for call to rest method
  $params = @{
    "Uri"     = $serverURL
    "Method"  = "POST"
    "Headers" = @{
      "X-Api-Key" = $authKey
    }
    "Body"    = (@{
        "name"          = "royashbrook"
        "date"          = get-date -Format "yyyy-MM-ddTHH:mm:ssK"
        "requests_sent" = $requests_sent
      }) | convertto-json
  }

  #call rest method, calculate pass/fail
  $measure = measure-command {
    try {
      $res = Invoke-RestMethod @params
      if ("$res" -eq "@{successful=True}") { $res = 1 }
      else { $res = 0 }
    } catch {
      $res = 0
    }
  }

  #return results from thread
  "{0},{1},{2}" -f $requests_sent, $res, $measure.TotalMilliseconds
}

# loop until break/esc
do {

  #start jobs up to max concurrency, assume this will take one second at least to complete
  # so we'll hit our target immediately, or will be slower
  $measure = measure-command {

    #spin up batches up to our max
    $currentRPS..($currentRPS += $targetRPS - 1) | % {
      $null = Start-ThreadJob -ThrottleLimit $targetRPS -ScriptBlock $sb `
        -ArgumentList $serverURL, $authKey, $_
    }

    #get results into csv
    get-job | Receive-Job -Wait -AutoRemoveJob | add-content $logfile

  }

  #write progress to console
  $totalRequests += $targetRPS
  $actual = [int]($targetRPS / $measure.TotalSeconds)
  $pct = [int](($actual / $targetRPS) * 100)
  $param = @{
    Activity = "Requests per Second"
    Status = "$pct% of target - $actual/$targetRPS"
    PercentComplete = $pct
  }
  if ($pct -gt 100) { $param.PercentComplete = 100 }
  Write-Progress @param

} while ($(
  #break on esc key
  if (!$Host.UI.RawUI.KeyAvailable) {
    $true
  } else {
    $key = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyUp,IncludeKeyDown")
    $key.VirtualKeyCode -ne 27
  }))

#after break, provide summary
$end = get-date
$data = Import-Csv $logfile
$SuccessPct = ($data | Measure-Object -average res).Average * 100
$avgMs = ($data | Measure-Object -average ms).Average
$totalMs = ($data | Measure-Object -sum ms).sum
$totalRequests = ($data | Measure-Object).count
"{0}: {1}" -f "Host Tested".PadRight(50), $serverURL
"{0}: {1}" -f "Total Requests Sent".PadRight(50), $totalRequests
"{0}: {1}" -f "Total Time Elapsed (s)".PadRight(50), [int]($totalMs / 1000)
"{0}: {1}" -f "Requests per Second".PadRight(50), [int]($totalRequests / ($end-$start).TotalSeconds)
"{0}: {1}" -f "Target Requests per Second".PadRight(50), $targetRPS
"{0}: {1}" -f "Average Response Time (ms)".PadRight(50), $avgMs
"{0}: {1}" -f "Success Rate".PadRight(50), [int]$SuccessPct
"{0}: {1}" -f "Log File".PadRight(50), $logfile