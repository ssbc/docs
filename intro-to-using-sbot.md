# Introduction to Using Scuttlebot

This guide will help you familiarize with Scuttlebot's API, both from the command-line and in applications, so you can build scripts and applications.

If you're not yet familiar with Scuttlebot's database protocol, Secure Scuttlebutt, I recommend you read ["Learn about SSB"](./learn.md) first, as it will explain a lot of the basic technical concepts more fully.
If you haven't installed Scuttlebot yet, follow the [setup Instructions](./README.md#setup-scuttlebot).

Table of Contents:

 - Basic concepts
  - [Connecting via RPC](#connecting-via-rpc)
  - [The CLI / RPC relationship](#the-cli-/-rpc-relationship)
  - [Pull-streams](#pull-streams)
  - [MuxRPC](#muxrpc)
 - Learn the API
  - [Basic Queries](#basic-queries)
  - [Publishing Messages](#publishing-messages)
  - [Advanced Queries](#advanced-queries)
  - [Live Streaming](#live-streaming)
  - [Confidential Messages](#confidential-messages)
 - Plugin APIs
  - [Blobs](#blobs)
  - [Friends](#friends)
  - [Gossip](#gossip)
  - [Invite](#invite)
  - [Private](#private)
  - [Replicate](#replicate)


## Basic concepts

### Connecting via RPC

<todo how to setup the rpc client>

### The CLI / RPC relationship

Scuttlebot's CLI translates directly from the shell to RPC calls.
That means any call you can make programmatically can be made from the shell as well.

Every API document shows the usage for both environments.

### Pull-streams

Pull-streams are the tool that Scuttlebot uses to stream data.
In most cases, you'll use them like this:

```js
pull(
  sbot.someQuery(),
  pull.drain(
    function (msg) {
      // process the message as it arrives
    },
    function (err) {
      // stream is over
    }
  )
)
```

Or, like this:

```js
pull(
  sbot.someQuery(),
  pull.collect(function (err, msgs) {
    // process all the messages after the stream ends
  })
)
```

But, the neat thing about pull-streams is how composable they are:

```js
pull(
  sbot.someQuery(),
  pull.filter(function (msg) {
    // filter out non-post messages
    return msg.value.content.type == 'post'
  }),
  pull.asyncMap(function (msg, cb) {
    // fetch the author's profile from storage
    fetchUser(msg.value.author, function (err, profile) {
      if (err) cb(err)
      else {
        msg.authorProfile = profile
        cb(null, msg)
      }
    })
  })
  pull.collect(function (err, msgs) {
    // process all the messages after the stream ends
  })
)
```

Check out these resources to understand them better:

 - [Library repository](https://github.com/dominictarr/pull-stream) - Minimal, pipable, streams.
 - A Primer for Pull-streams: [The Basics (part 1)](https://github.com/dominictarr/pull-stream-examples/blob/master/pull.js) and [Duplex Streams (part 2)](https://github.com/dominictarr/pull-stream-examples/blob/master/duplex.js)
 - [Source Functions](https://github.com/dominictarr/pull-stream/blob/master/docs/sources.md)
 - [Through Functions](https://github.com/dominictarr/pull-stream/blob/master/docs/throughs.md)
 - [Sink Functions](https://github.com/dominictarr/pull-stream/blob/master/docs/sinks.md)

### MuxRPC

[MuxRPC](https://github.com/ssbc/muxrpc) is Scuttlebot's protocol for multiplexing requests over a single connection.
Its commands translate directly to function invocations.

MuxRPC supports 4 different kinds of functions:

 - Async. The standard Javascript pattern of `fn(param1, param2..., cb)`
 - Source. A pull-stream source.
 - Sink. A pull-stream sink.
 - Duplex. A pull-streak source & sink.

It also has a helper `sync` type, which behaves like an `async` function in the protocol, but can be written like a syncronous function that returns a value instead of calling a cb.

All of Scuttlebot's API methods are one of these 5 types.


## Learn the API

In these sections, you may refer to the [API Docs](https://github.com/ssbc/scuttlebot/blob/master/api.md).

### Basic Queries

<todo>

### Publishing Messages

<todo>

### Advanced Queries

<todo>

### Live Streaming

<todo>

### Confidential Messages

<todo>


## Plugin APIs

Scuttlebot includes a set of optional behaviors in the form of plugins.
All of the plugins sbot includes are enabled, by default.
That means you can use their APIs.

### Blobs

<todo>

### Friends

<todo>

### Gossip

<todo>

### Invite

<todo>

### Private

<todo>

### Replicate

<todo>