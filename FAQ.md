# secure-scuttlebutt FAQ

This document is about ideas of how features from common web apps *could* be implemented.
Some features would be a little more complicated in ssb than a normal web app, but others would be simpler. At least, for most things, there is at least a viable way to create a given feature in a decentralized way.

## how does user identity work?

User identity is represented as the hash of the user's public key.
This means it is not necessary to have a global registry of user names,
nor to have a central server that tracks the action of users. Instead, every user action (post) is signed, and this can be verified by any peer.

## what does a message look like

here is an example message. the top level properties are all mandatory, but the user may set anything inside the `content` property, as long as there is a `type` field which is a string between 3 and 64 characters long. (up to 64 characters long so that they type may be represented by a hash)

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

The `previous` is the hash of the message before this in the feed signed by `author`. `author` is the hash of the public key which verifies this feed. the key pair for this feed *may not* be used for other feeds.

## what are links?

links are hashes of objects. there are three types of links: feed links, message links, and external links. All links also have a "rel(ation) type" which indicate the meaning of that link. A link is represented as a json object.

All links are a json property of the form
``` js
<rel>: {<type>: <hash>}
```

`type` may be `feed` `msg` or `ext`. `rel` may be any string, and <hash> must be a valid hash.

A feed link is the same as a user identity (the hash of a public key) and refers to a feed.
A message link is the hash of a particular message. An external link is the hash of file (also known as an attachment)

### backlinks

Since you replicate all your friends data locally, if someone replies or links to your message
then you will have that data, and to it's easy to show related messages. Messages can refer to each other, and you can see what messages link back to a given message. Post a photo and then someone can create a thread about it -> instant comment feature. Post a module, and then the comment system becomes an issue system, etc, etc

## why is there a size limit on messages?

Messages are limited it 1kb in size so that the time required to replicate is predictable.
Also, since peers will replicate all messages for peers they follow, it's important that peers do not create an unreasonable amount of work for each other.

If you need a larger object, use "attachments"

## Attachments

Attachments are immutable blobs of binary data, similar to email attachments. When clients see a message that refers to a given attachment, it will request it if the peer does not already have that attachment. Attachments are limited to 10mb. Replication of larger files could be implemented by integrating bittorrent (or even better, [webtorrent](https://github.com/feross/webtorrent)

## how do new users join the system

To join the network, a user needs to know a server in the system, to have their data replicated,
they need someone to follow them. The simplest way to join the network is to use an invite code.
The invite code contains the address of a pub server, and a secret that lets the server know it's
okay to replicate them. If you run your own pub server you can create invite codes and give them to your friends. 

## why do you have pub servers? isn't that a point of centralization?

wifi routers (Network Address Translation "NAT") and the shortage of ip addresses make p2p difficult. The simplest way around this problem was to create "pub servers". A pub server is exactly like a normal client, except you run it on a server with a static ip address. "pub" as in a bar where your friends meet to exchange gossip. Anyone can run a pub server. It's not centralization because pub servers are totally generic (same code as "clients") and because if we did have ipv6 and full p2p ssb would still work without any changes.

Also note that ssb also detects other peers running on your local network (wifi) and connects to them directly (without pub servers)

## how do I reserve my user name?

SecureScuttlebutt does not have traditional user names, because that would require a central registry of names, and then the system would not be decentralized.

Instead ssb uses a [pet name](http://www.skyhunter.com/marcs/petnames/IntroPetNames.html) system. Pet names are different to how user names normally work on the internet, but similar to how nick names actually work in real life -- your friends choose your name, instead of you choosing your own name. You may request others call you something (choose your own name), but friends ultimately decide. If your friends all agree to call you _Bob_, that _is your name_.

If an attacker tries to pretend to be you, it's up to your friends to notice and flag them.

This could also be applied to avatars - your friends could choose the profile pic for you.

(implemented in phoenix)

## preventing harassment / spam

Harassment is a problem on most online services. the normal approach is to give users block or mute buttons or to have moderators. All of these could be implemented on top of secure-scuttlebutt

### mute

Mute is the simplest, because a client just doesn't display posts from a muted feed, however, the muted user could still see the muter's feed.

### block

To block a user, it should prevent that user from getting your data. To block a user, a blocker posts a message telling their friends not to distribute their data to the blocked user. Then, when the blocked user requests the blocker's data, the blocker's friends simply pretend they do not have it. This does require some trust that the other users have correctly implemented clients. (but, it only requires that you _trust your friends_, which seems reasonable)

Since it is necessary to post a message to say a given user is blocked, it might be possible for that user to find out they have been blocked if they are able to get that message another way (i.e. by maintaining multiple identities)

See also: privacy/group encryption

### moderators

Another approach is that you delegate the job of deciding who to block to a designated user. In centralized services the administrators normally choose the moderator, but since ssb has no administrator, each user would appoint their own moderator. A related approach would be to "sympathetically block" if a friend was being harassed, you could set your client to also block users that are blocked by your friend. Showing your loyalty, and giving their blocks more impact.

## is it possible to delete or edit messages?

secure-scuttlebutt is immutable, so strictly speaking you cannot change anything that has been published, but instead of mutable messages, you can create "documents" that are represented as a series of changes to an initial message.

### delete

A true delete is not possible, instead you post a message that asks your friends to _ignore_ the message. This is somewhat like real life - if you say something embarrassing, the best you can do is ask your friends not to repeat it. Life is much better when you have good friends.

### edit

Editable documents can be represented by posting an init message, and then posting a message that refers to that message, and overrides properties on that message, or applies patches to sections of that message. By declaring lists of who may or may not edit documents, you could implement access controls.

Given that secure-scuttlebutt is a gossip system, and you only replicate your friend's messages,
this probably wouldn't scale to a wikipedia style global encyclopedia, in which you do not have a personal (or indirect) connection to authors of an article. This may be possible, but it would probably require a different architecture and replication protocol to secure-scuttlebutt.
There is still a lot of things you could build with ssb, and we have to leave some computer science for future generations to discover!

## could games be built on top of ssb?

ssb would be quite suitable for turn based games.

Generally games are competitive, and so to ensure fairness, requires consistency, i.e. turns. 
In some games, player move in a given order (i.e. in a card game, players move on at a time)
In other games, players make moves simultaneously (i.e. in rock paper scissors) 
(this is distinct from collaborative tasks such as wiki editing which are cooperative and are generally fine with eventual consistency).

This would be similar to editable documents, except that there would be well defined order that edits must occur in.

### perfect information games: chess / checkers / go

often in strategy games, all players know all information (except the plan of their opponent) this could be easily implemented by posting messages that indicated the move taken, from the previous game state.

### Rock Paper Scissors

In Rock Paper Scissors players reveal a secret simultaneously (their move) this could be implemented securely by using a [commitment protocol](https://en.wikipedia.org/wiki/Commitment_scheme)

### Poker

Poker could be implemented securely (though, with more than 2 players you would have to trust other players not to collude, as you would in real life). shortly after inventing RSA encryption Shamir, Rivest, Adleman developed a system for secure online poker. [mental poker](https://en.wikipedia.org/wiki/Mental_poker)

I am not currently aware of any online poker site that uses their system however. Online poker depends on a trusted server (imagine playing poker around a table, but the dealer holds the cards face up, and shuffles behind a screen. And yes, there have been [scandals](http://freakonomics.com/2007/10/17/the-absolute-poker-cheating-scandal-blown-wide-open/) where poker sites have had backdoors and have had house players that knew what cards the other players have!

## consistent data

Sometimes you would want to make sure that other users are aware of a given change. (this is very similar to a turn based game) this could be implemented by having "empty edits" that acknowledge a given change (one example might be making a todo task as "started" so that two people do not try to do the same thing at the same time)

## Is SSB highly available (AP) or highly consistent (CP)?

SSB is highly-available (AP). Devices can create messages while offline, then synchronize later. This means all data is _generally_ eventually-consistent. It is possible to build a CP system on top of an AP system (but not the other way around). see [consistent data](#consistent_data)

## Can I know if I have the latest messages from somebody?

No, because it's possible for devices to drop and continue operating (a network "partition.") There's a proposal to used signed pings to measure the "freshness" of a feed, however this could only be used in small groups of interested peers.

### Is there a global total order in SSB?

No. Although there is a global [partial order](http://en.wikipedia.org/wiki/Partially_ordered_set#Formal_definition). An individual Feed has a internal [total order](http://en.wikipedia.org/wiki/Total_order). Every message contains a pointer to the previous message in that feed, so this allows a feed to be totally ordered. If feed A posts a message that links to a message in feed B, then we know that A's message is *after* B's. (because to know the hash of an object, that object must already exist)

Messages also contain [monotonically increasing](http://en.wikipedia.org/wiki/Monotonic_function) UTC timestamps and sequence numbers, this means you can assign an order to any two messages,
however, there is no way to know that a timestamp really is correct.

## deploy applications

It would be possible to deploy applications over ssb by sending the javascript/etc for that application as an attachment. Then other users could run that app, which could provide an interface into a subset of ssb messages.

we have two ideas about how applications could work: (more development is necessary to decide which is better, or if both have their use)

### isolated feed applications

An application could connect to your local sbot server and run it's own feed, and maintain it's own keys, having complete control over the content of it's own messages. the user could then select which other feeds that application can see - i.e. which feeds are "friends" of that application.

This approach would also be useful when one user has multiple devices.

### shared feed applications

shared feed applications would have permission create and read certain types of messages. Maybe a photo application could create and read messages with `"type": "photo"` but not any other type.

## how would application updates be deployed?

Applications would be represented as a mutable document that posts to update the latest version of the code. Users could "install" this app, and their client would then download that code and run it in a sandbox, with some access to their local server.

## how do you know it is safe to run an application?

Applications would be run in a sandbox, and since new versions of the application would be immutably published it would always be possible to see the history of that application. This would actually be much more secure that a normal web application. In a normal website your browser just downloads code and runs it, while it does run it in a sandbox, it would be entirely possible to send one person a special version of the code that contained a targeted backdoor. Since in ssb everyone will see the same history, it would be impossible to attack a single user like this, with out eventually being caught out.

### auditing applications

Some applications require a higher quality standard. For example, encrypted messaging applications,
or the core ssb code may need to be updated, and should be independently audited before it is run.

Since performing a security audit is a highly skilled task, most users will not be able to perform their own security audit. In this case, the user could "delegate" the auditing task to another user (or users) who perform the audit, posting a message declaring a given version safe to run. Since the user can choose their auditors independently, it would mean an attacker would have to compromise the developers and many auditors in order to get people to install malicious code.

Auditing could also be applied to application permissons - of course, the decision about what permissions is reasonable for a given application is much simpler than looking at code and checking there is nothing unsafe.
