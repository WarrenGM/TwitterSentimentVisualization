http = require "http"
fs = require "fs"
twitterData = require "./twitter_analysis"

###
  IO
###
files = {}

fs.readdir "./public/", (err, files) ->
  if err
    throw err
  fileToString files[0], "d3"
  fileToString files[1], "html"
  fileToString files[2], "javascript"
    
fileToString = (fileName, property) -> 
  fs.readFile ("./public/" + fileName), (err, file) ->
    if err
      throw err
    files[property] = file
      
### 
  SERVER RESPONSES
###
respond = (request, response) -> 
  switch request.url
    when "/"
      response.writeHead(200, { "Content-Type": "text/html", })
      response.write(files.html)
    when "/d3_min.js"
      response.writeHead(200, { "Content-Type": "application/javascript", })
      response.write(files.d3)
    when "/index.js"
      response.writeHead(200, { "Content-Type": "application/javascript", })
      response.write(files.javascript)
    when "/get/data.json"
      response.writeHead(200, { "Content-Type": "application/json", })
      response.write(twitterData.getData())
    when "/favicon.ico"
      response.writeHead(200, { "Content-Type": "text/html", })
      response.write("")
    else
      response.writeHead(404, { "Content-Type": "text/html", })
      response.write("not found")
  response.end()
    
http.createServer(respond).listen(8000);