async = require "async"
help = require "../src/help"

module.exports =
  setUp: help.setUp
  tearDown: help.tearDown

  testSpread: (test) ->
    async.waterfall [
      (fall) => @engine.follow @entity1, @entity2, fall
      (fall) => @engine.post @entity2, { msg: @string }, fall
      (uid, fall) => @engine.sent @entity2, 0, 10, fall
      (data, fall) =>
        test.equal data.length, 1
        test.equal data[0].msg, @string
        @engine.inbox @entity1, 0, 10, fall
    ], (err, data) =>
      test.ifError err
      test.equal data.length, 1
      test.equal data[0].msg, @string
      test.done()

  testSprinkle: (test) ->
    async.waterfall [
      (fall) => @engine.post @entity2, { msg: @string }, fall
      (uid, fall) => @engine.sent @entity2, 0, 10, fall
      (data, fall) =>
        test.equal data.length, 1
        test.equal data[0].msg, @string
        @engine.follow @entity1, @entity2, fall
      (fall) => @engine.inbox @entity1, 0, 10, fall
    ], (err, data) =>
      test.ifError err
      test.equal data.length, 1
      test.equal data[0].msg, @string
      test.done()
