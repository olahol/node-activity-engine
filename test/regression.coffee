async = require "async"
help = require "../src/help"

exports.module =
  setUp: help.setUp
  tearDown: help.tearDown
  testStorage: (test) ->
    @engine.insert @entity2, { msg: @string }, (err, uid) =>
      test.ifError err
      @engine.lookup uid, (err, data) =>
        test.ifError err
        @engine.lookup @string, (err, data) =>
          test.ok err
          test.done()
  testReading: (test) ->
    @engine.sent @entity2, 0, 10, (err, data) =>
      test.ifError err
      test.equal data.length, 0
      async.timesSeries 10, (n, next) =>
        setTimeout =>
          @engine.post @entity2, { msg: n }, next
        , 1
      , (err) =>
        async.parallel [
          (par) =>
            @engine.sent @entity2, 0, 5, (err, data) =>
              test.ifError err
              test.equal data.length, 5
              test.deepEqual (a.msg for a in data), [9,8,7,6,5]
              par err
          , (par) =>
            @engine.sent @entity2, 5, 5, (err, data) =>
              test.ifError err
              test.equal data.length, 5
              test.deepEqual (a.msg for a in data), [4,3,2,1,0]
              par err
        ], (err) =>
          test.done()
  testRelations: (test) ->
    @engine.follow @entity1, @entity2, (err) =>
      async.timesSeries 10, (n, next) =>
        setTimeout =>
          @engine.post @entity2, { msg: n }, (err) =>
            @engine.post @entity1, { msg: 10 + n }, next
        , 1
      , (err) =>
          @engine.inbox @entity1, 0, 5, (err, data) =>
            test.ifError err
            test.equal data.length, 5
            test.deepEqual (a.msg for a in data), [9,8,7,6,5]
            @engine.follow @entity2, @entity1, (err) =>
              test.ifError err
              @engine.inbox @entity2, 0, 6, (err, data) =>
                test.ifError err
                test.equal data.length, 5
                test.deepEqual (a.msg for a in data), [19,18,17,16,15]
                test.done()
