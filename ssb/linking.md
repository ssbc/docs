# Content-Hash Linking

Messages, feeds, and blobs are addressable by specially-formatted identifiers.
Message and blob IDs are content-hashes, while feed IDs are public keys.

To indicate the type of ID, a "sigil" is prepended to the string. They are:

 - `@` for feeds
 - `%` for messages
 - `&` for blobs

Additionally, each ID has a "tag" appended to indicate the hash or key algorithm.
Some example IDs:

 - A feed: `@LA9HYf5rnUJFHHTklKXLLRyrEytayjbFZRo76Aj/qKs=.ed25519`
 - A message: `%MPB9vxHO0pvi2ve2wh6Do05ZrV7P6ZjUQ+IEYnzLfTs=.sha256`
 - A blob: `&Pe5kTo/V/w4MToasp1IuyMrMcCkQwDOdyzbyD5fy4ac=.sha256`

---

When IDs are found in the messages, they may be treated as links, with the keyname acting as a "relation" type.
An example of this:

```bash
sbot publish --type post \
  --root "%MPB9vxHO0pvi2ve2wh6Do05ZrV7P6ZjUQ+IEYnzLfTs=.sha256" \
  --branch "%kRi8MzGDWw2iKNmZak5STshtzJ1D8G/sAj8pa4bVXLI=.sha256" \
  --text "this is a reply!"
```
```js
sbot.publish({
  type: "post",
  root: "%MPB9vxHO0pvi2ve2wh6Do05ZrV7P6ZjUQ+IEYnzLfTs=.sha256",
  branch: "%kRi8MzGDWw2iKNmZak5STshtzJ1D8G/sAj8pa4bVXLI=.sha256",
  text: "this is a reply!"
})
```

In this example, the `root` and `branch` keys are the relations.
SSB automatically builds an index based on these links, to allow queries such as "all messages with a `root` link to this message."

---

If you want to include data in the link object, you can specify an object with the id in the `link` subattribute:

```bash
sbot publish --type post \
  --mentions.link "@LA9HYf5rnUJFHHTklKXLLRyrEytayjbFZRo76Aj/qKs=.ed25519" \
  --mentions.name bob \
  --text "hello, @bob"
```
```js
sbot.publish({
  type: "post",
  mentions: { 
    link: "@LA9HYf5rnUJFHHTklKXLLRyrEytayjbFZRo76Aj/qKs=.ed25519",
    name: "bob"
  },
  text: "hello, @bob"
})
```

---

To query the link-graph, use [links](https://github.com/ssbc/scuttlebot/blob/master/api.md#links-source):

```bash
sbot links [--source id|filter] [--dest id|filter] [--rel value]
```
```js
pull(sbot.links({ source:, dest:, rel: }), pull.drain(...))
```

You can provide either the source or the destination.
Both can be set to a sigil to filter; for instance, using `'&'` will filter to blobs, as `&` is the sigil that precedes blob IDs.
You can also include a relation-type filter.

Here are some example queries:

```bash
# all links pointing to this message
sbot links \
  --dest %6sHHKhwjVTFVADme55JVW3j9DoWbSlUmemVA6E42bf8=.sha256

# all "about" links pointing to this user
sbot links \
  --rel about \
  --dest @hxGxqPrplLjRG2vtjQL87abX4QKqeLgCwQpS730nNwE=.ed25519

# all blob links from this user
sbot links \
  --dest "&" \
  --source @hxGxqPrplLjRG2vtjQL87abX4QKqeLgCwQpS730nNwE=.ed25519
```
```js
// all links pointing to this message
pull(
  sbot.links({
    dest: '%6sHHKhwjVTFVADme55JVW3j9DoWbSlUmemVA6E42bf8=.sha256'
  }),
  pull.drain(...)
)

// all "about" links pointing to this user
pull(
  sbot.links({
    rel: 'about',
    dest: '@hxGxqPrplLjRG2vtjQL87abX4QKqeLgCwQpS730nNwE=.ed25519'
  }),
  pull.drain(...)
)

// all blob links from this user
pull(
  sbot.links({
    dest: '&',
    source: '@hxGxqPrplLjRG2vtjQL87abX4QKqeLgCwQpS730nNwE=.ed25519'
  }),
  pull.drain(...)
)
```

---

A common pattern is to recursively fetch the links that point to a message, creating a tree.
This is useful for creating comment-threads, for instance.

You can do that easily in scuttlebot with [relatedMessages](https://github.com/ssbc/scuttlebot/blob/master/api.md#relatedmessages-async).

```bash
sbot relatedMessages --id {id}
```
```js
sbot.relatedMessages({ id: id }, cb)
```