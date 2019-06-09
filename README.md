# Documentation

Get started with Scuttlebot and the Secure Scuttlebutt protocol.

## Links

- Scuttlebot implemented by [`ssb-server`](http://ssbc.github.io/ssb-server/): a p2p log store
- Secure Scuttlebutt implemented by [`ssb-db`](http://ssbc.github.io/ssb-db/): a global database protocol
- [Patchwork](http://ssbc.github.io/patchwork/): a social messaging app built on `ssb-server` and `ssb-db`

## Glossary

 - **Secure-Scuttlebutt (SSB)** - A protocol for replicating logs in a global gossip network.
 - **Scuttlebot** - An SSB server.
 - **Feeds** - a user's stream of signed messages. Also called a log.
 - **Gossip** - a P2P networking technique where peers connect randomly to each other and ask for new updates.
 - **Pub Servers** - SSB peers which run on public IPs, and provide connectivity and hosting for users on private IPs. Pubs are not privileged, and do not hold special authority in the network. They are not hosts.
 - **Invite codes** - Tokens which may be used to command specific Pub servers to follow a user. These are used to join Pubs.
