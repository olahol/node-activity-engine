idgen = require "idgen"

Engine = require("./index").Engine

exports.setUp = (done) ->
  @namespace = "test_" + idgen()
  @entity1   = idgen()
  @entity2   = idgen()
  @string    = idgen()
  @engine = new Engine
    host: process.env["REDIS_HOST"] || "127.0.0.1"
    port: process.env["REDIS_PORT"] || 6379
    namespace: @namespace
  done()

exports.tearDown = (done) -> @engine.destroy done
