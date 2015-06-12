If it is possible for an anyone to connect to a computer system then it may be possible to interfere with the operation of that system, and defenses against interference must be designed in.

For example, email's design is vulnerable spam. To send someone an email all that is required is to have their email address, email is unsolicited messaging so it's easy to send nuance or fraud emails.

Email systems deal with spam by filtering it out, there are two basic approaches:
The simplest is *pattern matching* - messages are compared to models of the sort of messages that spammers send. This produces a arms race between spammers and spam filterers. Spammers must strive to create messages which beat the filter, while filterers have to improve their model.

One particularly interesting example of this is (snail) mail advertisers that employ use [handwriting services](http://www.writeonresults.com/) to write the addresses on their envelopes - this fools the receiver into believing that an actual human sent them the letter making them much more likely to open it. 
this is being [automated](https://hellobond.com/)

The other approach is to use social/trust networks. services like facebook or twitter are significantly less vulnerable to spam. Instead of receiving messages form anyone one who knows your id/address on a social network you only receive messages from other users you have "followed" or "friended". I like to could call this a "Solicited Spam" system. Following someone on twitter means you think they are human, or at least, an amusing bot. This is actually a pretty strong signal. Email doesn't an explicit social network, but the best spam filtered email systems (like gmail) can use the implicit social network in email: if I send you and email and you reply then we are "friends".

Then graph analysis can be applied to the friend network - spammers may be isolated, or clustered together and can be filtered out.

By building secure-scuttlebutt around a social network, preventing spam becomes easy. Since in a social network application you only communicate with trusted peers (friends) anyway, and there is usually an explicit "follow" mechanism which expresses who you trust, and humans are pretty good at detecting frauds.