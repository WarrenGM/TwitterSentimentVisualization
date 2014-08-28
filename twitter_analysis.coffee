Twit = require "twit"
keys = require "./keys.json"
total = require "./learning/total.json"
count = require "./learning/count.json"

total["prob_pos"] = Math.log(total["pos"]/total["total"])
total["prob_neg"] = Math.log(total["neg"]/total["total"])

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
   analyzeTweet(tweet.text, hashtags)

analyzeTweet = (tweet, hashtags) ->
  pos = isPositive(tweet)
  property = if pos then "pos" else "neg"

  for tag in hashtags
    if buffer[tag]
      buffer[tag][property]++
    else
      buffer[tag] = {
        "pos": 1 * pos,
        "neg": 1 * !pos
      }
  tweet

isPositive = (tweet) -> 
  probPositive = logProb("pos", tweet)
  probNegative = logProb("neg", tweet)
  return probPositive > probNegative
  
# returns log P(C | W_1, ... , W_n)
# sentiment: "pos" or "neg"
logProb = (sentiment, tweet) ->
  words = tweet.match(/(\w+)/g)
  probability = 0
  for word in words
    term = count[word]
    if term
      probability += Math.log(term[sentiment] / total[sentiment])
      
  probability += total["prob_" + sentiment]
  return if probability == 0 then Number.NEGATIVE_INFINITY else probability
  
swapBuffers = () ->
  temp = buffer
  buffer = {}
  
  temp = new () -> 
    @[k] = temp[k] for k of temp when temp[k]["pos"] + temp[k]["neg"] > 1
    @ # return this
  bufferString = JSON.stringify(temp)
  
# Swaps buffers every 5 seconds
setInterval(swapBuffers, 5000)

# Returns current tweet data in JSON format
exports.getData = () -> bufferString