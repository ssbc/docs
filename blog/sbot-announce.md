# Announcing Scuttlebot

**Sept 25, 2015**

We're happy to announce a developer-ready build of [Scuttlebot](https://github.com/ssbc/scuttlebot) today.
You can download it now to play with the command-line tool and API.
We also have [pub servers](https://github.com/ssbc/scuttlebot/wiki/Pub-servers) available for general use.


## Summary

Secure Scuttlebutt (SSB) is a P2P database protocol of

- Per-user append-only logs of messages (i.e. [kappa architecture](http://www.kappa-architecture.com/))
- Content-addressable storage (i.e. `obj.id == hash(obj)`)
- Message distribution over a [gossip network](https://en.wikipedia.org/wiki/Gossip_protocol)

Think of it like a distributed twitter, with an 8kb limit instead of 140 characters.

[Scuttlebot](https://github.com/ssbc/scuttlebot) is a program to publish and syncronize SSB logs.
It can publish the data publicly, or with end-to-end encryption.
The blob-syncronization protocol distributes files as well.


### Confidentiality

Web applications are great at connectivity, but bad at confidentiality.
Desktop applications are the reverse: confidential, but not connective.
Scuttlebot is for applications that want to have the best of both: confidential operation, and great connectivity.

For private sharing, Scuttlebot uses [libsodium](http://doc.libsodium.org/) to encrypt confidential log-entries.
Log IDs are public keys, and so once two logs are mutually following each other, they can exchange confidential data freely.


### Autonomy

The joy of desktop computing is the creative freedom it gives you.
When networks stop you from making your own applications, then something's wrong.
Scuttlebot leaves the business-logic in the client, so that users are free to alter their applications.

The Scuttlebot network is an autonomous mesh.
Each computer runs independently, and does not have to trust its peers to exchange data.
If users can't connect directly, they use public nodes to rehost their logs.


## Get Started

Join us in #scuttlebutt on freenode.

#### [Install Scuttlebot](./README.md#setup-scuttlebot)

Setup instructions.

#### [Learn about Secure Scuttlebutt](../learn.md)

How the SSB network works, along with general Q&A.

#### [Introduction to Using Scuttlebot](../intro-to-using-sbot.md)

This guide steps through the CLI and API, so you can begin writing your own scripts and applications.
