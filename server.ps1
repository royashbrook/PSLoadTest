$http = [System.Net.HttpListener]::new() 
$http.Prefixes.Add("http://localhost:8080/")
$http.Start()
"started"
while ($http.IsListening){
  $cx = $http.GetContext()
  [System.IO.StreamReader]::new($cx.Request.InputStream).ReadToEnd()
  $cx.Response.OutputStream.Close()
  if($cx.Request.RawUrl -contains '/kill'){break;}
}
$http.Dispose()