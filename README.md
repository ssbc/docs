# Secure Scuttlebutt

![Hermies the Hermit Crab](https://avatars2.githubusercontent.com/u/10190339?v=3&s=200)

Secure Scuttlebutt (SSB) is a P2P database of message-feeds.
It consists of

- Per-user append-only logs of messages (i.e. [kappa architecture](http://www.kappa-architecture.com/))
- Content-addressable storage (i.e. `obj.id == hash(obj)`)
- Message distribution over a [gossip network](https://en.wikipedia.org/wiki/Gossip_protocol)

[Scuttlebot](https://github.com/ssbc/scuttlebot) is an SSB server.

 - [Guide to setup Scuttlebot, the SSB Server](#setup-scuttlebot)
 - [Introduction to using and developing with Scuttlebot](./intro-to-using-sbot.md)
 - [Learn about the Secure Scuttlebutt Protocol](./learn.md)

Join us in #scuttlebutt on freenode.

#### Secure Gossip Networking

SSB is a [P2P gossip network](https://en.wikipedia.org/wiki/Gossip_protocol).
This means that information is able to distribute across multiple machines, without requiring direct connections between them.

![Gossip graph](./gossip-graph1.png)

Even though Alice and Dan lack a direct connection, they can still exchange feeds:

![Gossip graph 2](./gossip-graph2.png)

This is because gossip creates "transitive" connections between computers.
Dan's messages travel through Carla and the Pub to reach Alice, and visa-versa.
Because all feeds are signed, if Dan has confirmed Alice's pubkey, then Dan doesn't have to trust Carla *or* the Pub to receive Alice's messages from them.

> Graphs created with [Gravizo](http://www.gravizo.com/)

#### Network Integrity

To make sure the network converges to the correct state, Scuttlebot uses the append-only log [CRDT](https://en.wikipedia.org/wiki/Conflict-free_replicated_data_type).
The append-only constraint is enforced with a blockchain structure: each entry includes the hash of the previous message.
If a peer receives a message with a `previous` hash that doesn't match its local cache, it'll reject the offending message.
(There is no Proof-of-Work; each log maintains an independent order.)

#### Message Semantics

Messages and links in SSB are typed, but SSB doesn't try to impose any validation or schemas.
Each message is a simple JSON object:

```js
{
   type: 'post', // the only required field
   text: 'Hello, @alice!',
   mentions: [{
      link: '@hxGxqPrplLjRG2vtjQL87abX4QKqeLgCwQpS730nNwE=.ed25519',
      name: 'alice'
   }]
}
```

This is a `post`-type message with a `mentions`-type link.
Scuttlebot creates indexes on these types.
Interpretation and validation is left to the applications, per the [Kappa Architecture](http://www.kappa-architecture.com/).

Each user maintains a separate log, and each log is an ordered list of these messages.
Scuttlebot [provides an API](./intro-to-using-sbot.md) for querying and streaming these logs.

#### Confidentiality and Spam-prevention

For private sharing, Scuttlebot uses [libsodium](http://doc.libsodium.org/) to encrypt confidential log-entries.
Log IDs are public keys, and so once two logs are mutually following each other, they can exchange confidential data freely.

Spam is a fundamental problem any network design.
Email is famously vulnerable to spam.
To send someone an email, all that is required is to have their address.
This allows unsolicited messaging.

Scuttlebot uses an explicit "follow" mechanism, to opt into logs to receive.
We call this "Solicited Spam."
Follows are published, and then graph analysis can be applied to the friend network - spammers may be isolated, or clustered together and filtered out.

#### Glossary

 - **Secure-Scuttlebutt (SSB)** - A protocol for replicating logs in a gossip network.
 - **Scuttlebot** - An SSB server.
 - **Feeds** - a user's stream of signed messages. Also called a log.
 - **Gossip** - a P2P networking technique where peers connect randomly to each other and ask for new updates.
 - **Pub Servers** - SSB peers which run on public IPs, and provide connectivity and hosting for users on private IPs. Pubs are not privileged, and do not hold special authority in the network. They are not hosts.
 - **Invite codes** - Tokens which may be used to command specific Pub servers to follow a user. These are used to join Pubs.


## Links

**Software**

 - [Scuttlebot](https://github.com/ssbc/scuttlebot) - A secure-scuttlebutt server.

**Guides**

 - [Setup Scuttlebot](#setup-scuttlebot)
 - [Learn About SSB](./learn.md)
 - [Introduction to Using Scuttlebot](./intro-to-using-sbot.md)
 - [Informal Pub Servers Registry](https://github.com/ssbc/scuttlebot/wiki/Pub-servers)

**Articles**

 - [Design Challenge: Avoiding Centralization and Singletons](./articles/design-challenge-avoid-centralization-and-singletons.md)
 - [Design Challenge: Sybil Attacks](./articles/design-challenge-sybil-attack.md)
 - [Using Trust in Open Networks](./articles/using-trust-in-open-networks.md)

**API Docs**

 - [Scuttlebot API](https://github.com/ssbc/scuttlebot/blob/master/api.md)
 - Scuttlebot Plugins
   - [Blobs](https://github.com/ssbc/scuttlebot/blob/master/plugins/blobs.md)
   - [Block](https://github.com/ssbc/scuttlebot/blob/master/plugins/block.md)
   - [Friends](https://github.com/ssbc/scuttlebot/blob/master/plugins/friends.md)
   - [Gossip](https://github.com/ssbc/scuttlebot/blob/master/plugins/gossip.md)
   - [Invite](https://github.com/ssbc/scuttlebot/blob/master/plugins/invite.md)
   - [Private](https://github.com/ssbc/scuttlebot/blob/master/plugins/private.md)
   - [Replicate](https://github.com/ssbc/scuttlebot/blob/master/plugins/replicate.md)

**Libraries**
 - [secure-scuttlebutt](https://github.com/ssbc/secure-scuttlebutt) - Wraps leveldb with tools for reading, writing to, and replicating feeds. Used internally by Scuttlebot.
 - [ssb-msg-schemas](https://github.com/ssbc/ssb-msg-schemas) - A collection of common message schemas.
 - [ssb-msgs](https://github.com/ssbc/ssb-msgs) - Message-processing tools.
 - [ssb-ref](https://github.com/ssbc/ssb-ref) - Check if a string is an SSB reference (used in linking).
 - [muxrpc](https://github.com/ssbc/muxrpc) - Lightweight multiplexed rpc.
 - [pull-stream](https://github.com/dominictarr/pull-stream) - Minimal, pipable, streams.
   - A Primer for Pull-streams: [The Basics (part 1)](https://github.com/dominictarr/pull-stream-examples/blob/master/pull.js) and [Duplex Streams (part 2)](https://github.com/dominictarr/pull-stream-examples/blob/master/duplex.js)
   - [Pull Sources](https://github.com/dominictarr/pull-stream/blob/master/docs/sources.md)
   - [Pull Throughs](https://github.com/dominictarr/pull-stream/blob/master/docs/throughs.md)
   - [Pull Sinks](https://github.com/dominictarr/pull-stream/blob/master/docs/sinks.md)


### Join a Pub

If you want to connect to your friends across the net, you need to be followed by a Pub server.

First get an invite-code from a pub owner you know.
You can find a pub in the [Informal Pub Servers Registry](https://github.com/ssbc/scuttlebot/wiki/Pub-servers).

Then:

```
sbot invite.accept $CODE
```

Your scuttlebot will now connect to, and sync with, the pub.
Other users can sync with the pub to receive your log.

