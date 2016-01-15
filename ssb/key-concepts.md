# Key Concepts

## Feeds and Users

SSB's primary data-structure is the append-only log, known also as the "feed."
Feeds are used by applications to build more sophisticated data-structures.

The database contains many feeds.
Each feed has one owner user, and each user can only write to one feed.
Therefore, you can think of feeds and users as interchangeble concepts.

Each feed is managed by an elliptic-curve keypair.
The public key acts as the ID of the feed.
The private key is used to sign each message on the feed.
Keypairs can not be reused for multiple feeds.


## The Blockchains

A signed blockchain structure is used to ensure feed-consistency across the network.
The signature proves authorship, making it possible for messages to be gossipped over untrusted peers.
The prev-hashes reveal changes to history, stopping users from altering their old messages after publishing.
With these protections, the network can converge on one universal state.

Some blockchain protocols, such as Bitcoin and Ethereum, create one global blockchain.
This requires coming to consensus about the order of messages in the blockchain.
Proof-of-Work computation is used to create this consensus.
Because SSB contains many feeds, and each feed is maintained by a single user, there is no need to come to consensus about order.
This is because the owning user asserts the feed's order, and thus could only conflict with itself.
Therefore, no proof-of-work is required.


## Trust Graphs

SSB uses trust-graphs between feeds to solve discovery, and to protect against spam and sybil attacks.
This is presented to users as a social network.
Users choose which feeds to follow, and each follow is published on their feed, creating a public follow-graph.

The follow-graph is used to reduce spam, by only allowing followeds to reach the inbox with mail.
It is also used as a signal to identify mutual friends, similar to how PGP's Web-of-Trust works.

Users can flag feeds for bad behavior, and these flags are also published, creating a flag-graph.
Flagged users may be blocked from syncing with regions of the network.


## Gossip Replication

When a connection is opened between nodes, they ask each other for any updates in their follow-lists.
Because feeds are sequential append-only logs, the gossip handshake is a simple list of `(feed-id, seq)` tuples.
If the receiving peer has messages for a feed with a `seq` number greater than given in the handshake, it streams them to the other peer.

Gossip provides transitive connectivity through-out the network.
This is enables sync between nodes which can't connect directly via intermediary nodes.


## LAN and Internet connectivity

SSB is hostless: each computer installs the same copy of software and has equal rights in the network.
Devices discover each other over the LAN with multicast UDP and sync automatically.

To sync across the Internet, "Pub" nodes run at public IPs and follow users.
They are essentially mail-bots which improve uptime and availability.
Users generate invite-codes to command Pubs to follow their friends.
The SSB team runs some Pubs, but anybody can create and introduce their own.


## Using SSB

Secure Scuttlebutt is a [Kappa Architecture](http://www.kappa-architecture.com/) API.
Applications pull the feeds' messages in a stream, and use them to compute "views" of the current state.
The views can be computed by application code, or by a database engine like SQLite or PostgreSQL after converting the messages to `INSERT` statements.

SSB stores received messages in a LevelDB instance on the local disk.
By default, it creates indexes for quickly reading streams of messages by type, by author, and by links.



## Blobs

The Scuttlebot server watches the incoming messages of followed users for blob links.
When a blob link is detected, it queries its peers for the blob, and downloads the blob to a local cache if found.
