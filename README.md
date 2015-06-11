# Secure Scuttlebutt

Secure-scuttlebutt is pre-beta.
You can download and test the software, but please be prepared to deal with issues.
We're working hard to package the beta!

**Repos:**

 - [Scuttlebot](https://github.com/ssbc/scuttlebot) - The main application. Includes the database, networking, command-line tools, and web ui.
 - [Secure-Scuttlebutt](https://github.com/ssbc/secure-scuttlebutt) - The core database library. Wraps leveldb with tools for reading, writing to, and replicating feeds.
 - [Phoenix](https://github.com/ssbc/phoenix) - The web ui for scuttlebot.


## About

Secure Scuttlebutt is a decentralized network which gossips blockchains in a peer-to-peer mesh.
It is an alternative to hosted Web applications, with greater protections for user data and greater freedom to choose your software.

### Gossip replication

Users follow each other to choose which blockchains they want.
When a connection is opened between nodes, they ask each other for any updates in their follow-lists.

Because the blockchains are sequential, append-only logs, the gossip handshake is a simple list of `(feed-id, seq)` tuples.
If the receiving peer has messages for a feed with a `seq` number greater than given in the handshake, it streams them to the other peer.

To give a broader connection to the social network, ssb also replicates friends-of-friends by default.

### The Blockchains

User data is published on signed blockchains.
Unlike Bitcoin, these blockchains require no proof-of-work or global sync, because each user runs their own independent chain.

The signed blockchain structure is used to ensure consistency across the network.
The signature proves authorship, making it possible for messages to be gossipped among peers.
The prev-hashes reveal changes to history, stopping users from altering their old messages after publishing.
With these protections, the network can converge on one universal state.

### The Web-of-Trust

"Follows" are published on the chains, creating a searchable social graph.
As each follow includes the pubkey of its target, the follow-graph acts as a Web-of-Trust PKI.
Once you've connected to a friend, you can follow their friends to build your contact list.

The network also publishes other trust signals between users, including nicknames, profile pics, bios, and warning flags.
Using signed, append-only logs to publish identity information is similar to [Google's Certificate Transparency project](http://www.certificate-transparency.org/) for auditing CA issuances.

SSB uses [libsodium](http://doc.libsodium.org/) for signatures and encryption, and [blake2s](https://blake2.net/) for hashing.

### LAN and Internet connectivity

Secure Scuttlebutt is hostless: each computer installs the same copy of software and has equal rights in the network.
Devices discover each other over the LAN and sync automatically.

To sync across the Internet, "Pub" nodes run at public IPs and follow users.
They are essentially mail-bots which improve uptime and availability.
Users generate invite-codes to command Pubs to follow their friends.
The SSB team runs some Pubs, but anybody can create and introduce their own.

### SSB API

Secure Scuttlebutt is a [Kappa Architecture](http://www.kappa-architecture.com/) API.
Applications pull the blockchains' messages in a stream, and use them to compute "views" of the current state.
The views can be computed by application code, or by a database engine like SQLite or PostgreSQL after converting the messages to `INSERT` statements.

SSB stores received messages in a LevelDB instance on the local disk.
By default, it creates indexes for quickly reading streams of messages by type, by author, and by links.


## FAQ

### How does user identity work?

User identity is represented as the hash of the user's public key.
This means it is not necessary to have a global registry of user names,
nor to have a central server that tracks the action of users.
Instead, every user action (post) is signed, and this can be verified by any peer.

To evaluate the trustworthiness of a user, you look at information published by other trusted users about the target.
If trusted users have flagged the target, then it is a bad actor.
If trusted users have followed the target, then it is probably a good actor.

### What does a message look like?

Here is an example message.
The top level properties are all mandatory, but the user may set anything inside the `content` property, as long as there is a `type` field which is a string between 3 and 64 characters long. 
(The type is up to 64 characters long so that it may be represented by a hash.)

``` js
{
  "previous": "nvuoueskUW1exp9Bh0Wuxx1T135pFRUGRTTUzHb+lP4=.blake2s",
  "author": "wuDDnMxVtk8U9hrueDj/T0itgp5HJZ4ZDEJodTyoMdg=.blake2s",
  "sequence": 194,
  "timestamp": 1427166175860,
  "hash": "blake2s",
  "content": {
    "type": "post",
    "text": "test publish..."
  },
  "signature": "7e10kNfM3WODM+LxUELoFErVKrRrIQGZj/cSOddIBbS0K1RTQgVUv911ydFWlJc0ja3aMtu08aRb2vIqXZVpIA==.blake2s.k256"
}
```

The `previous` is the hash of the message before this in the feed signed by `author`.
`author` is the hash of the public key which verifies this feed. 
The key pair for this feed *may not* be used for other feeds.

### What are links?

Links are hashes of objects.
There are three types of links: feed links, message links, and external links.
All links also have a "relation type" which indicate the meaning of that link.
A link is represented as a json object.

All links are a json property of the form:

```js
<rel>: {<type>: <hash>}
```

`type` may be `feed` `msg` or `ext`.
`rel` may be any string, and `hash` must be a valid hash.

Here is an example link inside a message:

```js
"content": {
  "type": "post",
  "text": "test reply...",
  "repliesTo": { "msg": "nvuoueskUW1exp9Bh0Wuxx1T135pFRUGRTTUzHb+lP4=.blake2s" }
}
```

A feed link is the same as a user identity (the hash of a public key) and refers to a feed.
A message link is the hash of a particular message.
An external link is the hash of file (also known as an attachment).

#### Backlinks

Since you replicate all your friends data locally, if someone replies or links to your message then you will have that data, and to it's easy to show those linking messages.
Messages can refer to each other, and you can see what messages link back to a given message.

This is useful for creating trees of data.
Post a `type: photo` and then someone can create a `type: post` referring to it, acting as a comment system.
Post a code module, and then the comment system becomes an issue system, etc, etc.

### Why is there a size limit on messages?

Messages are limited at 8kb in size so that the time required to replicate is predictable.
Also, since peers will replicate all messages for peers they follow, it's important that peers do not create an unreasonable amount of work for each other.

If you need a larger object, use "attachments."

### What are attachments?

Attachments are immutable blobs of binary data, similar to email attachments.
When clients see a message that refers to a given attachment, it will request it if the attachment isn't already stored locally.
Attachments are limited to 10mb.

Replication of larger files could be implemented by integrating bittorrent (or even better, [webtorrent](https://github.com/feross/webtorrent).

### How do new users join the system?

To join the network, a user needs to know a server in the system.
To have their data replicated, they need someone to follow them.

The simplest way to join the network is to use an invite code.
The invite code contains the address of a pub server, and a secret that commands the server to follow (and therefore replicate) the invite's user.
If you run your own pub server you can create invite codes and give them to your friends.

### Why do you have pub servers? isn't that a point of centralization?

Routers with Network Address Translation ("NAT") and firewalls, and the shortage of IP addresses, make p2p difficult.
The simplest way around this problem was to create "pub servers".

A pub server is exactly like a normal client, except you run it on a server with a static IP address.
It's a "pub" as in a bar where your friends meet to exchange gossip.

Anyone can run a pub server.
It's not centralization because pub servers are totally generic (same code as "clients") and because, if we did have ipv6 and full p2p, ssb would work without any changes.
Also note that ssb also detects other peers running on your local network (wifi) and connects to them directly, without pub servers.

### How do I reserve my user name?

Secure Scuttlebutt does not have unique user names, because that would require a central registry of names, and then the system would not be decentralized.

Instead, ssb's nicknames can be set locally.
If two of your friends pick the same name, then you can rename one to disambiguate them.

The web interface alerts the user to name conflicts, so that this can be resolved quickly.

### How do we prevent harassment and spam?

Harassment is a problem on most online services.
The normal approach is to give users block or mute buttons or to have moderators.
All of these could be implemented on top of secure scuttlebutt.

Presently, there is a "flag" feature, which is an extremely strong negative signal.
If somebody is behaving poorly, feel free to flag them.

### Is it possible to delete or edit messages?

Secure Scuttlebutt is immutable, so strictly speaking you cannot change anything that has been published.
There are, however, abstractions on top of the feeds which allow behaviors like deletion and editing.

#### Delete

A true delete is not possible: instead, you post a message asking your friends to _ignore_ the message.
This is somewhat like real life - if you say something embarrassing, the best you can do is ask your friends to ignore it.
(Life is much better when you have good friends.)

#### Edit

Editable objects can be represented by posting a create message, and then posting a message that refers to that message and overrides properties on that message, or applies patches to it.
By declaring lists of who may or may not edit documents, you could implement access controls.

### Could games be built on top of ssb?

SSB would be quite suitable for turn based games.

Generally, games are competitive, and so ensuring fairness requires consistency, i.e. turns. 
In some games, player move in a given order (i.e. in a card game, players move one at a time).
In other games, players make moves simultaneously (i.e. in rock paper scissors).
(This is distinct from collaborative tasks such as wiki editing which are cooperative and are generally fine with eventual consistency.)

This would be similar to editable documents, except that there would be well defined order that "edits" must occur in.

#### Perfect information games: chess / checkers / go

Often in strategy games, all players know all information (except the plan of their opponent).
This could be easily implemented by posting messages that indicated the move taken from the previous game state.

#### Rock Paper Scissors

In Rock Paper Scissors players reveal a secret simultaneously (their move).
This could be implemented securely by using a [commitment protocol](https://en.wikipedia.org/wiki/Commitment_scheme).

#### Poker

Poker could be implemented securely (though, with more than 2 players you would have to trust other players not to collude, as you would in real life).
Shortly after inventing RSA encryption, Shamir, Rivest, Adleman developed a system for secure online poker called [mental poker](https://en.wikipedia.org/wiki/Mental_poker).

I am not currently aware of any online poker site that uses their system, however.
Online poker depends on a trusted server - imagine playing poker around a table, but the dealer holds the cards face up, and shuffles behind a screen.
And yes, there have been [scandals](http://freakonomics.com/2007/10/17/the-absolute-poker-cheating-scandal-blown-wide-open/) where poker sites have had backdoors and have had house players that knew what cards the other players have!

### How do you ensure data consistency between users?

Sometimes, you want to make sure that other users are aware of a given change.
This can be implemented by posting acknowledgement messages.

There is also active discussion about using signed pings to send ephemeral acknowledgements (off of the feeds).

#### Is SSB highly available (AP) or highly consistent (CP)?

SSB is highly-available (AP).
Devices can create messages while offline, then synchronize later.
This means all data is eventually-consistent.

#### Can I know if I have the latest messages from somebody?

No, because it's possible for devices to drop and continue operating (a network "partition").
There's a proposal to used signed pings to measure the "freshness" of a feed, but this could only be used in small groups of interested peers.

#### Is there a global total order in SSB?

No.
There is, however, a global [partial order](http://en.wikipedia.org/wiki/Partially_ordered_set#Formal_definition).

An individual feed has an internal [total order](http://en.wikipedia.org/wiki/Total_order).
Every message contains a sequence number and a pointer to the previous message in that feed.

If feed A posts a message that links to a message in feed B, then we know that A's message is *after* B's.
That is, message-links imply a `happens-before` relationship.
(This is because, in order to know the hash of an object, that object must already exist.)

Messages contain [monotonically increasing](http://en.wikipedia.org/wiki/Monotonic_function) UTC timestamps and sequence numbers.
This means you can assign an order to any two messages.
However, be aware that there is no way to ensure that the timestamp is accurate.

### Can I deploy applications over SSB?

It would be possible to deploy applications over ssb by sending the assets for that application as an attachment.
Then other users could run that app on their local machine.

We have plans to build on this in the future.

#### How will you know it is safe to run an application?

Applications would be run in a sandbox, and, since new versions of the application would be immutably published, it would always be possible to see the history of that application.
This would actually be much more secure that a normal web application.
In a normal website your browser just downloads code and runs it.
While it does run in a sandbox, it would be entirely possible to send one person a special version of the code that contained a targeted backdoor.
Since, in ssb, everyone will see the same history, it would be impossible to attack a single user like this without eventually being caught out.

#### Auditing applications

Some applications require a higher quality standard, especially if they need special rights to the device's resources.

Since performing a security audit is a highly skilled task, most users will not be able to perform their own security audit.
In this case, the user could "delegate" the auditing task to another user (or users) who perform the audit, posting a message declaring a given version safe to run.
Since the user can choose their auditors independently, it would mean an attacker would have to compromise the developers and many auditors in order to get people to install malicious code.

Auditing could also be applied to application permissons.
Of course, the decision about what permissions is reasonable for a given application is much simpler than looking at code and checking there is nothing unsafe.
