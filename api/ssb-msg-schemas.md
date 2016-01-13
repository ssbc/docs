# SSB Message Schemas

Functions to create common SSB messages.

```js
{ type: 'post', text: String, channel: String, root: MsgLink, branch: MsgLink, recps: FeedLinks, mentions: Links }
{ type: 'about', about: Link, name: String, image: BlobLink }
{ type: 'contact', contact: FeedLink, following: Bool, blocking: Bool }
{ type: 'vote', vote: { link: Ref, value: -1|0|1, reason: String } }
{ type: 'pub', pub: { link: FeedRef, host: String, port: Number } }
```


```js
var schemas = require('ssb-msg-schemas')

schemas.post(text, root (optional), branch (optional), mentions (optional), recps (optional), channel (optional))
// => { type: 'post', text: text, channel: channel, root: root, branch: branch, mentions: mentions, recps: recps }
schemas.name(id, name)
// => { type: 'about', about: id, name: name }
schemas.image(id, imgLink)
// => { type: 'about', about: id, image: imgLink }
schemas.follow(userId)
// => { type: 'contact', contact: userId, following: true, blocking: false }
schemas.unfollow(userId)
// => { type: 'contact', contact: userId, following: false }
schemas.block(userId)
// => { type: 'contact', contact: userId, following: false, blocking: true }
schemas.unblock(userId)
// => { type: 'contact', contact: userId, blocking: false }
schemas.vote(id, vote)
// => { type: 'vote', vote: { link: id, value: vote } }
schemas.vote(id, vote, reason)
// => { type: 'vote', vote: { link: id, value: vote, reason: reason } }
schemas.pub(id, host, port)
// => { type: 'pub', pub: { link: id, host: host, port: port } }
```

## Notes

### type: post

```js
{ type: 'post', text: String, channel: String, root: MsgLink, branch: MsgLink, recps: FeedLinks, mentions: Links }
```

 - `channel` is optionally used to filter posts into groups, similar to subreddits or chat channels.
 - `root` and `branch` are for replies.
   - `root` should point to the topmost message in the thread.
   - `branch` should point to the message in the thread which is being replied to.
   - In the first reply of a thread, `root === branch`, and both should be included.
   - `root` and `branch` should only point to `type: post` messages. If the post is about another message-type, use `mentions`.
 - `mentions` is a generic reference to other feeds, entities, or blobs.
   - It is used by user mentions (you typed "@bob", so bob's link goes in `mentions`).
   - It is used by file-attachments (you attached a file, the reference goes in `mentions`).
   - It is used by message-mentions (to reference non-post messages).
 - `recps` is a list of user-links specifying who the message is for.
   - This is typically used for encrypted messages, to specify who the message was encrypted for.

### type: about

```js
{ type: 'about', about: Link, name: String, image: BlobLink }
```

 - You should only include 1 votable piece of information at a time in an about message.
   - Of the attributes specified here, `name` and `image` are votable.
   - Therefore, `name` and `image` should not appear in the same message.
   - Reason: vote messages cant differentiate on content within a message. If `name` and `image` are grouped together, a vote on the message is a vote on both pieces of information.
 - Typically, `type: about` is for users, but it can also be used on msgs and blobs.