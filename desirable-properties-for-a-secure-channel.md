here is a list of properties that I think are desirable in a p2p secure channel. It is assumed that peers already know the pubkeys of a server. It may not be possible to support _all_ of these properties in one protocol.

1. content is forward secure
2. server verifies client identity
3. client verifies server identity
4. server knows client has verified
5. client knows server has verified
6. resists replay attack
7. resists man-in-the-middle attack
8. prevents cold calling/war-dialing (only accept calls from clients that know who server is)
9. eavesdropper cannot learn client key
10. eavesdropper cannot learn server key
11. eavesdropper cannot confirm client key
12. eavesdropper cannot confirm server key
13. replay attack cannot learn who is authorized
14. unauthorized client cannot learn server key.
15. unauthorized client cannot confirm server key
16. man in the middle cannot learn or confirm client or server keys

## requirements

how to achieve the above properties

## 1. forward secure content

Use diffie-helman style key exchange, an ensure a different key is used every connection.

## 2,3. verify identities

challenge the remote peer to provide a signature of a nonce.

## 4,5. know the remote has verified you

acknowledge their signed challenge by signing it.

## 6. resist replay attack

force peer to respond (sign) something you know is unique (nonce) (see 2,3)

## 7. resist man in the middle attack

verify identities & client must abort connection if response was from unexpected server.
Use diffie-helman to exchange keys (or box every message)

## 8. prevent cold-calling/war-dialing

client must prove it knows the server's pubkey.
This treats the pubkey as a write capability.

one method would be to box the hello to the server's pubkey.
Another option, would be to hmac with the server's pubkey.

## 9, 10. protect client/server keys from eavesdropper

do not send long term keys as plaintext.
It shouldn't be necessary to send the server key at all, given that the client has know business connecting to a server they don't know (see 8, prevent war dialing)

## 11, 12. eavesdropper cannot confirm client/server

If an eavesdropper happens to know the client or server's key, are they able to know it is those peers talking? This property protects the client's privacy in particular. The server is likely to be a staticly addressed server, so their key is likely to eventually become public knowledge. Although, in a p2p protocol it's likely that the server may also move.

The client on the other hand, is likely to be a mobile device that changes ip addresses. Being able to identify / observe their key would allow you to know track their location.

This property is stronger than 9,10 even if the eavesdropper knows the keys, they are unable to confirm the identity of the peer.

## 13. a replay attack cannot learn whether a given client is authorized on this server.

It would be easy for a eavesdropper to record client hellos, and then send them to random servers to see whether that client is authorized on that server. If the server rejects that connection before the client has proven their identity then this leaks information from the server's access list. The server should wait until the client has proved their identity before rejecting a connection.

## 14. unauthorized client cannot learn server key.

To realize this property it would be necessary for the client to auth to the server first.
This property seems reasonable - "hi this is Alice, is Bob there?" if Bob isn't talking to Alice, or if it's a wrong number the server responds "sorry wrong number" and hangs up. This will require an extra round trip, because a challenge must be issued to the client.

This property would prevent an active attacker from learning who a given server is.

## 15. unauthorized client cannot confirm server key.

This property is stronger than 14, because 14 means the server shouldn't reveal their key to an unauthorized client, but this property means the server should not give the client evidence incase the client already knows happens to know that key. This means a malicious client cannot get a list of keys (by some other mechanism) and check that those servers really are those keys.

to realize this property it is necessary for the client to authorize to the server first, and for the server to be able to reject the client without revealing any more information. 

## 16. MITM/wrong number cannot learn or confirm keys.

The client needs asymmetrically encrypt their authorization to the server, such that the server will act the same way whether the client is unauthorized, or just dialed a wrong number (unauthorized server)

