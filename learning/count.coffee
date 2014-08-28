fs = require "fs"
Twit = require "twit"
keys = require "../keys.json"

emoticons = [
  # Positive emoticons
  ":)", ":-)", ":D", ":-D",
  "=)", "=-)", "=D", "=-D",
  "8)", "8D", "8-)", "(8"
  "XD"
  "(:", "(-:", "(=",
  "^_^", "(^_^)", "^-^", "(^-^)"
  
  # Negative emoticons
  ":(", ":-(", ":\'(", ":\'-("
  "=(", "=\'("
  "D=", "D:", "D-:"
  ":/", ":-/", "=/"
  "-_-", "(-_-)"

]

negative = /([=:][']?[-]?[\/\(]|[D\)]-?[:=]|\(?-_-\)?)/
positive = /([=:8]-?[\)D3]|\([:=8]|\^[_-]\^|\([-\^]?[:=])/g

count = {}

finished = false

tweets = 0
positiveTweets = 0

dataSize = 100000

twitter = new Twit(keys)

stream = twitter.stream("statuses/filter", { track: emoticons, language: "en" })


stream.on "tweet", (tweet) ->
  if tweets > dataSize
    if !finished
      finish()
      finished = true;
  else
    classify(tweet.text)

classify = (tweet) ->
  if tweet.match(negative)
    updateCount(tweet, "neg")
  else
    updateCount(tweet, "pos")
    positiveTweets++
    
  tweets++
      
toUnigrams = (text) -> text.match(/(\w+)/g)

formatTweet = (text) -> 
  text.toLowerCase().replace(/([#|@][\w_]+|rt|http::\/\/t\.co\/\w+)/g, "")
  #toRemove = /([^\w\b])/g
    
updateCount = (tweet, property) ->
  unigrams = toUnigrams formatTweet(tweet)
  
  if unigrams == null
    return tweet;
    
  for word in unigrams
    if !count[word]
      count[word] = { "pos": 0, "neg": 0 } 
    
    count[word][property]++
  tweet
    
finish = () ->
  total = { 
    "total": tweets
    "positive": positiveTweets
    "negative": (tweets - positiveTweets)
  }
  
  quota = dataSize / 200  
  for k of count
    if count[k]["pos"] + count[k]["neg"] <= quota
      delete count[k]
      
  result = { "totals": total, "words": count }
  console.log JSON.stringify(total)

  fs.writeFile("result.json", JSON.stringify(result, null, 4), (err) ->
    if err
      throw err
        
    process.exit()
  )
  
  
