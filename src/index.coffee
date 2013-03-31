exports.version = "0.0.1"

_     = require "underscore"
redis = require "redis"
async = require "async"
idgen = require "idgen"

timeNow = -> (new Date).getTime()

exports.Engine = class Engine
  constructor: (options) ->
    @redis = options.redis || redis.createClient options.port, options.host
    @redis.auth options.password if options.password?
    @redis.select options.database if options.database?
    @length = options.length || 100
    @namespace = options.namespace || "astream"

  # Storage
  insert: (entity, data, cb) ->
    uid = "#{entity}:#{idgen()}"
    str = JSON.stringify data
    @redis.hset @formatKey("vault"), uid, str, (err) ->
      return cb(err) if err?
      cb null, uid

  lookup: (uid, cb) ->
    @redis.hget @formatKey("vault"), uid, (err, res) ->
      return cb(err) if err?
      return cb(new Error "uid #{uid} not found") unless res?
      data = JSON.parse res
      data.uid = uid
      cb null, data

  # Reading
  get: (stream, entity, offset, take, cb) ->
    stop = if take > 0 then offset + take - 1 else 0
    args = [@formatKey(entity, stream), offset, stop, "WITHSCORES"]
    @redis.zrevrange args, (err, res) ->
      return cb(err) if err?
      uids = (a for a, i in res when i % 2 is 0)
      scores = (a for a, i in res when i % 2 isnt 0)
      cb null, _.zip uids, scores

  stream: (stream, entity, offset, take, cb) ->
    @get stream, entity, offset, take, (err, res) =>
      return cb(err) if err?
      async.map res, (act, map) =>
        [uid, score] = act
        @lookup uid, map
      , cb

  sent: (entity, offset, take, cb) ->
    @stream "sent", entity, offset, take, cb

  inbox: (entity, offset, take, cb) ->
    @stream "inbox", entity, offset, take, cb

  # Writing
  put: (stream, entity, uid, cb, score = timeNow()) ->
    @redis.zadd @formatKey(entity, stream), score, uid, cb

  unput: (stream, entity, uid, cb) ->
    @redis.zrem @formatKey(entity, stream), uid, cb

  spread: (entity, uid, cb, score = timeNow()) ->
    @followers entity, (follower, each) =>
      @put "inbox", follower, uid, each, score
    , cb

  unspread: (entity, uid, cb) ->
    @followers entity, (follower, each) =>
      @unput "inbox", follower, uid, each
    , cb

  publish: (entity, data, cb, score = timeNow()) ->
    @insert entity, data, (err, uid) =>
      return cb(err) if err?
      @put "sent", entity, uid, (err) ->
        return cb(err) if err?
        cb null, uid
      , score

  post: (entity, data, cb, score = timeNow()) ->
    @publish entity, data, (err, uid) =>
      return cb(err) if err?
      @spread entity, uid, cb, score
    , score

  # Relations
  subscribe: (from, to, cb) ->
    @redis.sadd @formatKey(to, "followers"), from, cb

  unsubscribe: (from, to, cb) ->
    @redis.srem @formatKey(to, "followers"), from, cb

  sprinkle: (from, to, cb) ->
    @get "sent", to, 0, 5, (err, res) =>
      return cb(err) if err?
      async.each res, (act, each) =>
        [uid, score] = act
        @put "inbox", from, uid, each, score
      , cb

  unsprinkle: (from, to, cb) ->
    @get "sent", to, 0, @length, (err, res) =>
      return cb(err) if err?
      async.each res, (act, each) =>
        [uid, score] = act
        @unput "inbox", from, uid, each
      , cb

  follow: (from, to, cb) ->
    @subscribe from, to, (err) =>
      return cb(err) if err?
      @sprinkle from, to, cb

  unfollow: (from, to, cb) ->
    @unsubscribe from, to, (err) =>
      return cb(err) if err?
      @unsprinkle from, to, cb

  # Iterate over an entity's followers.
  followers: (entity, fn, cb) ->
    @redis.smembers @formatKey(entity, "followers"), (err, res) ->
      return cb(err) if err?
      async.eachSeries res, fn, cb

  # Misc
  end: ->
    @redis.quit()

  # WARNING: deletes all keys associated with @namespace
  destroy: (cb) ->
    @redis.keys "#{@namespace}:*", (err, keys) =>
      async.each keys, (key, each) =>
        @redis.del key, each
      , (err) =>
        @end()
        cb()

  formatKey: (args...) ->
    "#{@namespace}:" + args.join(":")
