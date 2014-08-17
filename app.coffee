http = require "http"
url = require "url"
Twit = require "twit"
fs = require "fs"
keys = require "./keys.json"

twitter = new Twit(keys)

# Most common words (for tracking)
words = [
  "the", "a" # articles
  "is", "are", "was" # to be
  "i", "me", "it", "you", "that", "there"
  "of", "and", "or", "in", "to"
  "would", "could", "should"
]
trending = {}

tweets = 0

buffer = {}
bufferString = "test"

###
  IO
###
files = {}

fs.readdir "./front_end/", (err, files) ->
  if err
    throw err
  fileToString files[0], "d3"
  fileToString files[1], "html"
  fileToString files[2], "javascript"
    
fileToString = (fileName, property) -> 
  fs.readFile ("./front_end/" + fileName), (err, file) ->
    if err
      throw err
    files[property] = file
  
### 
  STREAMING LOGIC
###
#stream = twitter.stream "statuses/filter",
#  { track: words, language: "en", filter_level: "medium"}

#stream.on "tweet", (tweet) -> 
# tweets++
# hashtags = tweet.text.match(/(#\w+)/g)
# if hashtags
#   tags++
#   analyzeTweet(tweet, hashtags)

analyzeTweet = (tweet, hashtags) ->
  for tag in hashtags
    if buffer[tag]
      buffer[tag]++
    else
      buffer[tag] = 1

swapBuffers = () ->
  console.log "swapping"
  temp = buffer
  buffer = {}
  
  temp = new () -> 
    @[k] = temp[k] for k of temp when temp[k] > 1
    @ # return this
  bufferString = JSON.stringify(temp)
  
# Swaps buffers every 5 seconds
setInterval swapBuffers, 5000
      
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
      response.write(bufferString)
    when "/favicon.ico"
      response.writeHead(200, { "Content-Type": "text/html", })
      response.write("")
    default
      response.writeHead(404, { "Content-Type": "text/html", })
      response.write("not found")
  response.end()
    
http.createServer(respond).listen(8000);

getData = (request, response) ->
  response.writeHead 200, { "Content-Type": "application/json"}
  response.write bufferString
  response.end()
  
createStream = () ->
  # create twitter stream
  # interval
    # swap buffers

sentiment = (tweet) -> (Math.random() < 0.5)
