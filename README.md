# node-activity-engine

WARNING: This project is still in alpha, use with caution.

A nimble and follower aware fan out activity stream framework that uses
Redis as backend.


## Why?

Activity streams are a major part of how people consume information
on the web today. Twitter's timeline is an activity stream where the
activities are tweets and they are ordered by time, Facebook's news
feed is an activity stream ordered by EdgeRank. This framework is for
managing such activity streams abstracting away they nitty-gritty of
routing activities to the right stream and ordering them.

This framework was inspired by the talk ["Timelines @
Twitter"](http://www.infoq.com/presentations/Timelines-Twitter) given
by Arya Asemanfar.

## Example

https://github.com/olahol/node-activity-engine/blob/master/examples/twitter.coffee

## Concepts

### Activity

A unique identifier, should usually be a key pointing to a database
row (for example a primary key in a SQL table).

### Activity stream

A list of activities ordered by their score (default score is time).

### Entity

Something that performs or receives activities, a user, a group, a tag,
an image etc. All entities have two activity streams, a `sent` activity
stream which consists of its own activities and an `inbox` activity stream
which consist of the activities of the entities it's following. Like an
activity an entity should usually be a key pointing to a database object,
show that metadata can be retrieved.

### Following

An entity can follow another entity, which means it will be routed
activies from that entitiy.

## API

### Engine.sent(entity, offset, take, cb(err, activities))
### Engine.inbox(entity, offset, take, cb(err, activities))

* * *

### Engine.post(entity, activity, cb(err))
#### Engine.put(entity, activity, cb(err))
#### Engine.spread(entity, activity, cb(err))

* * *

### Engine.unpost(entity, activity, cb(err))
#### Engine.unput(entity, activity, cb(err))
#### Engine.unspread(entity, activity, cb(err))

* * *

### Engine.follow(from, to, cb(err))
#### Engine.subscribe(from, to, cb(err))
#### Engine.sprinkle(from, to, cb(err))

* * *

### Engine.unfollow(from, to, cb(err))
#### Engine.unsubscribe(from, to, cb(err))
#### Engine.nub(from, to, cb(err))
