# Announcing Scuttlebot

**Sept 25, 2015**

We're happy to announce a developer-ready build of [Scuttlebot](https://github.com/ssbc/scuttlebot) today.
You can download it now to play with the command-line tool and API.
We also have [pub servers](https://github.com/ssbc/scuttlebot/wiki/Pub-servers) available for general use.


## Summary

Secure Scuttlebutt (SSB) is a P2P database of

- Per-user append-only logs of messages (i.e. [kappa architecture](http://www.kappa-architecture.com/))
- Content-addressable storage (i.e. `obj.id == hash(obj)`)
- Message distribution over a [gossip network](https://en.wikipedia.org/wiki/Gossip_protocol)

Think of it like a distributed twitter, with an 8kb limit instead of 140 characters.

[Scuttlebot](https://github.com/ssbc/scuttlebot) is a program to publish and syncronize SSB logs.
It can publish the data publicly, or with end-to-end encryption.
The blob-syncronization protocol distributes files as well.


## Confidentiality

Web applications are not good at confidentiality.
Scuttlebot is for desktop applications, that want to have shared networks.
User actions stay on the device, and only public data gets published.

Scuttlebot uses [libsodium](http://doc.libsodium.org/) to encrypt confidential log-entries.
Log IDs are public keys, and so once two logs are mutually following each other, they can exchange confidential data freely.


## Autonomy

The joy of desktop computing is the creative freedom it gives you.
When networks stop you from making your own applications, then something's wrong.

Scuttlebot puts the business-logic in the client.
This leaves users free to hack and fork their applications.

The Secure Scuttlebutt network is an autonomous mesh.
Each computer runs independently, and does not have to trust its peers to exchange data.
If users can't connect directly, they use public nodes to rehost their logs.

See also [Design Challenge: Avoid Centralization and Singletons](../articles/design-challenge-avoid-centralization-and-singletons.md)


## Integrity and Security

Scuttlebot [gossips its logs through the network](https://en.wikipedia.org/wiki/Gossip_protocol), and so the entries must be verifiable, without trusting the peers.
All log entries are signed by the authors' public keys, and public keys are used to identify the logs.

To make sure the network converges to the correct state, Scuttlebot uses the append-only log [CRDT](https://en.wikipedia.org/wiki/Conflict-free_replicated_data_type).
The append-only constraint is enforced with a blockchain structure: each entry includes the hash of the previous message.
If a peer receives a message with a `previous` hash that doesn't match its local cache, it'll reject the offending message.


## Spam-prevention

Email's design is vulnerable to spam.
To send someone an email, all that is required is to have their address.
Email is unsolicited messaging.

Scuttlebot uses an explicit "follow" mechanism, to opt into logs to receive.
We call this "Solicited Spam."
Follows are published, and then graph analysis can be applied to the friend network - spammers may be isolated, or clustered together and filtered out.

See also [Design Challenge: Sybil Attacks](../articles/design-challenge-sybil-attack.md)


## Usage

Logs are a simple core abstraction for data structures of all kinds.
Applications compute views by streaming the messages into memory, computing a data-structure, and (optionally) writing the structure to a mutable cache.
This is called a [Kappa Architecture](http://www.kappa-architecture.com/).

For structures that multiple users can update, we recommend using [CRDTs](https://en.wikipedia.org/wiki/Conflict-free_replicated_data_type).

We've published [a documentation repo](https://github.com/ssbc/docs) to help you get started.
Follow the install instructions in the overview, then see the guides and API references.

[Lots more to read here.](../learn.md)