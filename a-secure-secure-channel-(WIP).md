Alice wants to connect to Bob and communicate privately. Also, we want to realize _all_ the [desireable properties for a secure channel](https://github.com/ssbc/scuttlebot/wiki/desirable-properties-for-a-secure-channel)

> Alice generates DH key, initiates duplex connection (i.e. tcp) to Bob. 

Alice: here is my dh key. (this message is not signed, Bob doesn't yet know it's Alice, and Alice isn't sure it's Bob yet either)
> Bob receives connection, generates DH key.
Bob: okay, here is my DH key.
> Alice and Bob now use the DH keys to generate a shared key. All further messages will be encrypted with this key and some cipher. Since the DH key is ephemeral and not related to either Alice or Bob's keys content is forward secure (1)

Alice (encrypted): hey hash(Bob), it's Alice, we are communicating in the session hash(Alice's dh key + Bob's dh key), here is another DH key (DH2), signed Alice.

> Alice reveals her identity (sends public key, and signs it) . She also proves it's Bob that she desires to talk to (8). However, she does not say Bob's name, in case she has dialed a wrong number, or was intercepted. Bob will know it's really her, and not a replay, because she signed the dh key that he created just a second ago (2, 6).

Since Alice's greeting is encrypted, Eve cannot learn her public key, see her signature, nor the hash of Bob's key either. (9, 11) But since a man in the middle attack has not yet failed, a mitm _could_ learn Alice's identity & and could confirm that Alice is trying to speak to Bob (although nothing more).

> Bob now knows he is talking to Alice. If he doesn't like Alice, or doesn't know who Alice is, he can hang up the phone without revealing his identity. If Alice is a cold-calling telemarketer, she hasn't learnt anything about who lives at this number. (10, 12, 13, 14, 15) Bob knows Alice intended to call him too, so he knows she will authenticate him if he continues the call (4)

Bob (encrypted): hi Alice, you said hash(Alice's greeting), yes it's me, here is my new DH key (DH2) (signed Bob)
> Bob responds to Alice's greeting with a signature, now Alice knows it's him for sure, because he signed the hash of Alice's greeting, which contained a unique value she just generated (DH2) (3) and Bob did not hang up, so she knows she is verified with him (3), since he didn't hang up, Alice knows Bob has verified her (5) Alice knows she is not getting a man in the middle attack, because Bob signed the keys (via hash of Alice's greeting) and if there was a MITM they would have to use different keys with Bob.

> Alice and Bob are now mutually authenticated, encrypted from their first DH exchange, but they did a second key exchange inside of that, and now generate a new shared key and a new cipher and mac stream.
> now the content of their session may be encrypted then authenticated with the new shared key.

The inner layer of encryption is now tightly tied to their identities (via signatures) and forward secure because the dh keys are ephemeral and not tied to their private keys. (1)

## improvements

I think this design is _nearly there_. A mitm attack can learn who Alice is (her key) and confirm who she is trying to contact before the connection fails. This could be addressed if Alice boxed her greeting to bob with a temp identity, or used encrypted it to bob without signing it (which would allow mitm to confirm her identity). I havn't yet convinced my self about man in the middle attacks... need to understand key exchange better. It would not be necessary to encrypt bob's response, because by that stage the mitm attack would have failed.
