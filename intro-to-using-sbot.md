# Introduction to Using Scuttlebot

This guide will help you familiarize with Scuttlebot's API, both from the command-line and in applications, so you can build scripts and applications.

If you're not yet familiar with Scuttlebot's database protocol, Secure Scuttlebutt, I recommend you read ["Learn about SSB"](./learn.md) first, as it will explain a lot of the basic technical concepts more fully.
If you haven't installed Scuttlebot yet, follow the [setup instructions](./README.md#setup-scuttlebot).

 - Basic concepts
  - [Connecting via RPC](#connecting-via-rpc)
  - [The CLI / RPC relationship](#the-cli--rpc-relationship)
 - Learn the API
  - [Basic Queries](#basic-queries)
  - [Live Streaming](#live-streaming)
  - [Publishing Messages](#publishing-messages)
  - [Links](#links)
  - [Link Queries](#link-queries)
  - [Confidential Messages](#confidential-messages)
 - Plugin APIs
  - [Blobs](#blobs)
  - [Friends](#friends)
  - [Gossip](#gossip)
  - [Invite](#invite)
  - [Replicate](#replicate)


---


## Basic concepts

### Connecting via RPC

<todo how to setup the rpc client>

### The CLI / RPC relationship

Scuttlebot's CLI translates directly from the shell to RPC calls.
That means any call you can make programmatically can be made from the shell as well.


---


## Learn the API

### Basic Queries

The simplest query you can run is against the feed index, [createFeedStream](https://github.com/ssbc/scuttlebot/blob/master/api.md#createfeedstream-source).

```bash
./sbot.js feed
```
```js
pull(sbot.createFeedStream(), pull.drain(...))
```

This will output all of the messages in your scuttlebot, ordered by the claimed timestamp of the messages.
This index is convenient, but not safe, as the timestamps on the messages are not verifiable.

---

A more reliable query is the log index, [createLogStream](https://github.com/ssbc/scuttlebot/blob/master/api.md#createlogstream-source).

```bash
./sbot.js log
```
```js
pull(sbot.createLogStream(), pull.drain(...))
```

This will output all of the messages in your scuttlebot, ordered by when you received the messages.
This index is safer, but (in some cases) less convenient.

---

If you want to filter the messages by their type, use [messagesByType](https://github.com/ssbc/scuttlebot/blob/master/api.md#messagesbytype-source).

```bash
./sbot.js logt $type
```
```js
pull(sbot.messagesByType(type), pull.drain(...))
```

This will output all of the messages in your scuttlebot of the given type, ordered by when you received the messages.

---

Finally, if you want to fetch the messages by a single feed, use [createUserStream](https://github.com/ssbc/scuttlebot/blob/master/api.md#createuserstream-source)

```bash
./sbot.js createUserStream --id $id
```
```js
pull(sbot.createUserStream({ id: id }), pull.drain(...))
```

This will output all of the messages in your scuttlebot by that log, ordered by sequence number.

You can also use [createHistoryStream](https://github.com/ssbc/scuttlebot/blob/master/api.md#createhistorystream-source) to do the same, but with a simpler interface:

```bash
./sbot.js hist $id
```
```js
pull(sbot.createHistoryStream(id), pull.drain(...))
```

---

Also, remember you can fetch any message by ID using [get](https://github.com/ssbc/scuttlebot/blob/master/api.md#get-async):

```bash
./sbot.js get $id
```
```js
sbot.get(id, cb)
```

### Live Streaming

In most of the query methods, you can specify `live: true` to keep the stream open.
The stream will emit new messages as they're added to the indexes by gossip.

```bash
./sbot.js log --live
```
```js
pull(sbot.createLogStream({ live: true }), pull.drain(...))
```

### Publishing Messages

Publishing messages in Scuttlebot is very simple:

```bash
./sbot.js publish --type $type ...attributes
```
```js
sbot.publish({ type: type, ... }, cb)
```

Here's an example publish:

```bash
./sbot.js publish --type post --text "hello, world"
```
```js
sbot.publish({ type: 'post', text: 'hello, world' }, cb)
```

You are free to put anything you want in the message, with the following rules:

 - You must include a `type` attribute.
 - The output message, including headers, cannot exceed 8kb.

You can find [common message-schemas here](https://github.com/ssbc/ssb-msg-schemas).

### Links

Messages, feeds, and blobs are addressable by specially-formatted identifiers.
Message and blob IDs are content-hashes, while feed IDs are public keys.

To indicate the type of ID, a "sigil" is prepended to the string. They are:

 - `@` for feeds
 - `%` for messages
 - `&` for blobs

Additionally, each ID has a "tag" appended to indicate the hash or key algorithm.
Some example IDs:

 - A feed: `@LA9HYf5rnUJFHHTklKXLLRyrEytayjbFZRo76Aj/qKs=.ed25519`
 - A message: `%MPB9vxHO0pvi2ve2wh6Do05ZrV7P6ZjUQ+IEYnzLfTs=.sha256`
 - A blob: `&Pe5kTo/V/w4MToasp1IuyMrMcCkQwDOdyzbyD5fy4ac=.sha256`

When IDs are found in the messages, they may be treated as links, with the keyname acting as a "relation" type.
An example of this:

```bash
./sbot.js publish --type post --repliesTo "%MPB9vxHO0pvi2ve2wh6Do05ZrV7P6ZjUQ+IEYnzLfTs=.sha256" \
                  --text "this is a reply!"
```
```js
sbot.publish({
  type: "post",
  repliesTo: "%MPB9vxHO0pvi2ve2wh6Do05ZrV7P6ZjUQ+IEYnzLfTs=.sha256",
  text: "this is a reply!"
})
```

In this example, the `repliesTo` key is the relation.
SSB automatically builds an index based on these links, to allow queries such as "all messages with a `repliesTo` link to this message."

If you want to include data in the link, you can specify an object, and put the id in the `link` subattribute:

```bash
./sbot.js publish --type post --mentions.link "%MPB9vxHO0pvi2ve2wh6Do05ZrV7P6ZjUQ+IEYnzLfTs=.sha256" \
                  --mentions.name bob --text "hello, @bob"
```
```js
sbot.publish({
  type: "post",
  mentions: { 
    link: "@LA9HYf5rnUJFHHTklKXLLRyrEytayjbFZRo76Aj/qKs=.ed25519",
    name: "bob"
  },
  text: "hello, @bob"
})
```

### Link Queries

To query the link-graph, use [links](https://github.com/ssbc/scuttlebot/blob/master/api.md#links-source):

```bash
./sbot.js links [--source id|filter] [--dest id|filter] [--rel value]
```
```js
pull(sbot.links({ source:, dest:, rel: }), pull.drain(...))
```

You can provide either the source or the destination.
Both can be set to a sigil to filter; for instance, using `'&'` will filter to blobs, as `&` is the sigil that precedes blob IDs.
You can also include a relation-type filter.

Here are some example queries:

```bash
./sbot.js links --dest %6sHHKhwjVTFVADme55JVW3j9DoWbSlUmemVA6E42bf8=.sha256
./sbot.js links --rel about --dest @hxGxqPrplLjRG2vtjQL87abX4QKqeLgCwQpS730nNwE=.ed25519
./sbot.js links --dest "&" --source @hxGxqPrplLjRG2vtjQL87abX4QKqeLgCwQpS730nNwE=.ed25519
```
```js
pull(sbot.links({ dest: '%6sHHKhwjVTFVADme55JVW3j9DoWbSlUmemVA6E42bf8=.sha256' }), pull.drain(...))
pull(sbot.links({ rel: 'about', dest: '@hxGxqPrplLjRG2vtjQL87abX4QKqeLgCwQpS730nNwE=.ed25519' }), pull.drain(...))
pull(sbot.links({ dest: '&', source: '@hxGxqPrplLjRG2vtjQL87abX4QKqeLgCwQpS730nNwE=.ed25519' }), pull.drain(...))
```

A common pattern is to recursively fetch the links that point to a message, creating a tree.
This is useful for creating comment-threads, for instance.

You can do that easily in scuttlebot with [relatedMessages](https://github.com/ssbc/scuttlebot/blob/master/api.md#relatedmessages-async).

```bash
./sbot.js relatedMessages --id $id
```
```js
sbot.relatedMessages({ id: id }, cb)
```

### Confidential Messages

You can publish messages which are encrypted for up to 7 other recipients.
This is done with the `private` plugin.

First is [private.publish](https://github.com/ssbc/scuttlebot/blob/master/plugins/private.md#publish-async):

```js
sbot.private.publish({ type: type, ... }, recps, cb)
```

This works exactly like `sbot.publish`, but `recps` includes a list of feed-ids to encrypted the message for.

(Note, the CLI is currently not able to handle this function's signature.)

To decode a message, you use [private.unbox](https://github.com/ssbc/scuttlebot/blob/master/plugins/private.md#unbox-sync)

```js
sbot.private.unbox(ciphertext, cb)
```

An encrypted message's `content` attribute will be a string.
So, you can see that a message is encrypted with this check:

```js
function isEncrypted (msg) {
  return (typeof msg.value.content == 'string')
}
```

There is no way to see who an encrypted message is for.
If `unbox()` decrypts successfully, then you'll know the message was for you.

Note, Scuttlebot will attempt to decrypt all incoming messages, and add them to its indexes.


---



## Plugin APIs

Scuttlebot includes a set of optional behaviors in the form of plugins.
All of the plugins sbot includes are enabled, by default.
That means you can use their APIs.

### Blobs

The blobs plugin gives you access to a content-addressed files database.
[Here is the API](https://github.com/ssbc/scuttlebot/blob/master/plugins/blobs.md).

```bash
$ echo "hello, world" | ./sbot.js blobs.add
&hT/5N2Kgbdv3IsTr6d3WbY9j3a6pf1IcPswg2nyXYCA=.sha256
$ ./sbot.js blobs.get "&hT/5N2Kgbdv3IsTr6d3WbY9j3a6pf1IcPswg2nyXYCA=.sha256"
hello, world
```
```js
pull(
  pull.values(['hello, world']),
  sbot.add(function (err, hash) {
    if (err) throw err
    pull(pull.get(hash[0]), pull.collect(function (err, values) {
      if (err) throw err
      assert(values[0] == 'hello, world')
    }))
  })
)
```

---

In addition to getting/putting files, you can register that you `want` a file of a specific hash.
Scuttlebot will regularly poll peers for the blobs in its wantlist, and download them when found.

```bash
./sbot.js blobs.want "&hT/5N2Kgbdv3IsTr6d3WbY9j3a6pf1IcPswg2nyXYCA=.sha256" --nowait
```
```js
sbot.blobs.want("&hT/5N2Kgbdv3IsTr6d3WbY9j3a6pf1IcPswg2nyXYCA=.sha256", { nowait: true }, cb)
```

If you omit `nowait`, Scuttlebot will not call the `cb` until the blob is found.

You can also listen to the `changes` stream to see hashes of recently download blobs:

```bash
./sbot.js blobs.changes
```
```js
pull(sbot.blobs.changes(), pull.drain(...))
```

The blobs plugin works alongside the logs.
Any time Scuttlebot receives a log-entry that links to a blob, if the message's timestamp was in the last month, then Scuttlebot will add that blob to the want-list.

### Friends

The [friends plugin](https://github.com/ssbc/scuttlebot/blob/master/plugins/friends.md) gives you tools to analyze the follow-graph and flag-graph.
The two main methods: [all()](https://github.com/ssbc/scuttlebot/blob/master/plugins/friends.md#all-async) gives you the full graph, while [hops()](https://github.com/ssbc/scuttlebot/blob/master/plugins/friends.md#hops-async) tells you the connective distance from one user to all others.

### Gossip

The [gossip plugin](https://github.com/ssbc/scuttlebot/blob/master/plugins/gossip.md) controls the table of peers, and decides when to initiate route connections in order to syncronize.

You can list peers with [peers](https://github.com/ssbc/scuttlebot/blob/master/plugins/gossip.md#peers-sync), add peers with [add](https://github.com/ssbc/scuttlebot/blob/master/plugins/gossip.md#add-sync), add-and-connect peers with [connect](https://github.com/ssbc/scuttlebot/blob/master/plugins/gossip.md#connect-async), and listen for connectivity events with [changes](https://github.com/ssbc/scuttlebot/blob/master/plugins/gossip.md#changes-source).

### Invite

The [invites plugin](https://github.com/ssbc/scuttlebot/blob/master/plugins/invite.md) creates and uses invite-codes, which Pub servers use to add new members.
You can create new codes with [create](https://github.com/ssbc/scuttlebot/blob/master/plugins/invite.md#create-async) and use the codes with [accept](https://github.com/ssbc/scuttlebot/blob/master/plugins/invite.md#accept-async)

### Replicate

The [replicate plugin](https://github.com/ssbc/scuttlebot/blob/master/plugins/replicate.md) listens for new connections with peers and downloads updates for its followed logins.
It exposes the [changes](https://github.com/ssbc/scuttlebot/blob/master/plugins/replicate.md#changes-source) method so you can watch download progress.