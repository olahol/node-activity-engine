async = require "async"
help = require "../src/help"

module.exports =
  setUp: help.setUp
  tearDown: help.tearDown

  testUnspread: (test) ->
    async.waterfall [
      (fall) => @engine.follow @entity1, @entity2, fall
      (fall) => @engine.post @entity2, { msg: @string }, fall
      (uid, fall) => @engine.sent @entity2, 0, 10, fall
      (data, fall) =>
          test.equal data.length, 1
          test.equal data[0].msg, @string
          @engine.inbox @entity1, 0, 10, fall
      (data, fall) =>
          test.equal data.length, 1
          test.equal data[0].msg, @string
          @uid = data[0].uid
          @engine.reference @entity2, data[0].uid, fall
      (fall) => @engine.unspread @entity2, @uid, fall
      (fall) => @engine.unreference @entity2, @uid, fall
      (fall) => @engine.inbox @entity1, 0, 10, fall
    ], (err, data) =>
      test.ifError err
      test.equal data.length, 0
      test.done()

  testUnsprinkle: (test) ->
    async.waterfall [
      (fall) => @engine.follow @entity1, @entity2, fall
      (fall) => @engine.post @entity2, { msg: @string }, fall
      (uid, fall) =>  @engine.sent @entity2, 0, 10, fall
      (data, fall) =>
        test.equal data.length, 1
        test.equal data[0].msg, @string
        @engine.inbox @entity1, 0, 10, fall
      (data, fall) =>
        test.equal data.length, 1
        test.equal data[0].msg, @string
        @engine.unfollow @entity1, @entity2, fall
      (fall) => @engine.inbox @entity1, 0, 10, fall
    ], (err, data) =>
      test.ifError err
      test.equal data.length, 0
      test.done()
