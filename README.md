# node-activity-engine

A nimble and follower aware fan out activity stream framework that uses
Redis as backend.

# Why?

Activity streams are a major part of how people consume information
on the web today. Twitter's timeline is an activity stream where the
activities are tweets and they are ordered by time, Facebook's news
feed is an activity stream ordered by EdgeRank. This framework is for
managing such activity streams abstracting away they nitty-gritty of
routing activities to the right stream and ordering them.

This framework was inspired by the talk ["Timelines @
Twitter"](http://www.infoq.com/presentations/Timelines-Twitter) given
by Arya Asemanfar.

# Example

# Concepts

## Activity

A unique identifier, should usually be a key pointing to a database
row (for example a primary key in a SQL table).

## Activity stream

A list of activities ordered by their score (default score is time).

## Entity

Something that performs or receives activities, a user, a group, a tag,
an image etc. All entities have two activity streams, a `sent` activity
stream which consists of its own activities and an `inbox` activity stream
which consist of the activities of the entities it's following. Like an
activity an entity should usually be a key pointing to a database object,
show that metadata can be retrieved.

## Following

An entity can follow another entity, which means it will be routed
activies from that entitiy.

# API

## ActivityStream.sent(entity, offset, take, cb(err, activities))
## ActivityStream.inbox(entity, offset, take, cb(err, activities))

* * *

## ActivityStream.post(entity, activity, cb(err))
### ActivityStream.put(entity, activity, cb(err))
### ActivityStream.spread(entity, activity, cb(err))

* * *

## ActivityStream.unpost(entity, activity, cb(err))
### ActivityStream.unput(entity, activity, cb(err))
### ActivityStream.unspread(entity, activity, cb(err))

* * *

## ActivityStream.follow(from, to, cb(err))
### ActivityStream.subscribe(from, to, cb(err))
### ActivityStream.sprinkle(from, to, cb(err))

* * *

## ActivityStream.unfollow(from, to, cb(err))
### ActivityStream.unsubscribe(from, to, cb(err))
### ActivityStream.nub(from, to, cb(err))
