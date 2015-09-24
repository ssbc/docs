# Design Challenge: Avoid Centralization and Singletons

SSB goes out of it's way to avoid both centralization and singletons.

## Avoiding Centralization

The danger of centralization is obvious: it creates a single point of failure that can easily be attacked.
To avoid centralization every peer is the same. Due to limitations inherent in the modern internet some peers must perform special roles - wifi routers (and maybe your isp) performs Network Address Translation to make a single IP address function like many. This makes it simple to make outgoing connections, but difficult to receive incoming connections. Normally, networked applications solve this by centralizing - clients connect to a single addressable server. Sometimes p2p systems use clever techniques ([TURN](http://en.wikipedia.org/wiki/Traversal_Using_Relays_around_NAT) [STUN](http://en.wikipedia.org/wiki/STUN) [ICE](http://en.wikipedia.org/wiki/Interactive_Connectivity_Establishment) ) to get around this, but it's still necessary to have *some* servers that are likely to be addressable (known as a "bootlist" or "startlist").

Pub servers should not be considered as centralizations because your content is likely to be stored on _multiple pub servers_. A pub server may go down, and others will still provide service -- contrast this with email servers, which are onstensibly decentralized (you may run your own email server) however, you must have *exactly one* email server, and if it is down you will not receive email -- which makes running your own email server a considerable hassle (not to mention handling spam)

Also, pub servers could be extended to act at WebRTC introducers, bootstrapping true p2p for browser applications.

## Avoiding Singletons

SecureScuttlebutt also avoids p2p structures that represent singletons - specifically, it avoids using a [Distributed Hash Table](http://en.wikipedia.org/wiki/Distributed_hash_table) and a [global blockchain](http://en.wikipedia.org/wiki/Bitcoin#Block_chain) (ssb uses personal blockchains per-identity)

SSB avoids p2p singletons partially to show that it can be done (most p2p designs use DHT or global blockchains) and also because those are just p2p versions of centralized systems. Social Networks are already constructed around a decentralized experience. Popular social networks (fb, twitter) have centralized implementations, but you use them to interact with your _peers_ so on that level they are p2p.

SSB takes this decentralized experience and maps the networking layer (the key part of the implementation) on top of the decentralized human/user network. It would be a shame to go to all that trouble to decentralize, but then adopt a singleton. Also, global blockchains are heavy (require nodes to store entire chain, and to waste CPU power) and DHTs are susceptible to spam. These structures also both make the network unprivate, by making all information available globally.

## Remaining Singletons

Arguably the protocol and implementation are singletons. It's easy to imagine that multiple people re-implement the protocol. Since secure scuttlebutt is implemented around a simple [rpc protocol](https://github.com/ssbc/muxrpc) it will be simple to extend the protocol. Strategies for upgrading the protocol itself have been [discussed](https://github.com/ssbc/scuttlebot/issues/139)