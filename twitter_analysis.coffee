Twit = require "twit"
keys = require "./keys.json"

twitter = new Twit(keys)

# Most common words (for tracking)
words = [
 # "the", "a" # articles
  "is", "are", "was", "were" # to be
  "i", "me", "it", "you", "that", "they"
  #"he", "him", "she", "her", "we", 
  "of", "and", "or", "in", "to"
  #"would", "could", "should"
]
trending = {}

tweets = 0

buffer = {}
bufferString = "test"

### 
  STREAMING LOGIC
###
stream = twitter.stream "statuses/filter",
  { track: words, language: "en", filter_level: "medium"}

stream.on "tweet", (tweet) -> 
 tweets++
 hashtags = tweet.text.match(/(#\w+)/g)
 if hashtags
   analyzeTweet(tweet, hashtags)

analyzeTweet = (tweet, hashtags) ->
  for tag in hashtags
    if buffer[tag]
      buffer[tag]++
    else
      buffer[tag] = 1

swapBuffers = () ->
  temp = buffer
  buffer = {}
  
  temp = new () -> 
    @[k] = temp[k] for k of temp when temp[k] > 1
    @ # return this
  bufferString = JSON.stringify(temp)
  
# Swaps buffers every 5 seconds
setInterval(swapBuffers, 5000)

# Returns current tweet data in JSON format
exports.getData = () -> bufferString