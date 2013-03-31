async = require "async"
help = require "../src/help"

module.exports =
  setUp: help.setUp
  tearDown: help.tearDown
  testSpread: (test) ->
    @engine.follow @entity1, @entity2, (err) =>
      test.ifError err
      @engine.post @entity2, { msg: @string }, (err) =>
        test.ifError err
        @engine.sent @entity2, 0, 10, (err, data) =>
          test.ifError err
          test.equal data.length, 1
          test.equal data[0].msg, @string
          @engine.inbox @entity1, 0, 10, (err, data) =>
            test.ifError err
            test.equal data.length, 1
            test.equal data[0].msg, @string
            test.done()
  testSprinkle: (test) ->
    @engine.post @entity2, { msg: @string }, (err) =>
      test.ifError err
      @engine.sent @entity2, 0, 10, (err, data) =>
        test.ifError err
        test.equal data.length, 1
        test.equal data[0].msg, @string
        @engine.follow @entity1, @entity2, (err) =>
          test.ifError err
          @engine.inbox @entity1, 0, 10, (err, data) =>
            test.ifError err
            test.equal data.length, 1
            test.equal data[0].msg, @string
            test.done()
