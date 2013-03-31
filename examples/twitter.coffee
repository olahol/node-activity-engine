express = require "express"
redis   = require "redis"
idgen   = require "idgen"

Engine = require("../src").Engine

redisClient = redis.createClient()

engine = new Engine
  redis: redisClient
  namespace: idgen()

app = express()
app.engine "jade", require("jade").__express
app.set "views", __dirname + "/views"
app.set "view engine", "jade"
app.use express.logger("tiny")
app.use express.bodyParser()
app.use app.router

# redis keys we are going to use
usersKey = "#{engine.namespace}:twitter:users"
followingKey = (username) -> "#{engine.namespace}:#{username}:following"

app.get "/", (req, res) ->
  res.redirect "/user/" + idgen()

app.get "/user/:username", (req, res) ->
  username = req.params.username
  redisClient.sadd usersKey, username # lets keep track of how many users there are
  redisClient.smembers usersKey, (err, users) ->
    redisClient.smembers followingKey(username), (err, following) ->
      engine.inbox username, 0, 25, (err, inbox) ->
        engine.sent username, 0, 25, (err, sent) ->
          res.render "twitter",
            inbox: inbox
            sent: sent
            users: users
            following: following
            username: username

app.post "/tweet", (req, res) ->
  username = req.body.username
  activity = # approximation of activitystrea.ms protocol
    published: new Date()
    actor: username
    verb: "tweet"
    content: req.body.tweet.substring 0, 140
  engine.post username, activity, (err) ->
    res.redirect "back"

app.post "/follow", (req, res) ->
  from = req.body.from
  to   = req.body.to
  redisClient.sadd followingKey(from), to # track following
  engine.follow from, to, (err) ->
    res.redirect "back"

app.listen 3000, ->
  console.log "Starting twitter example"
