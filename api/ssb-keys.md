# SSB-Keys

A common module for secure-scuttlebutt projects, provides an API to create or load elliptic-curve keypairs and to execute related crypto operations.

```js
var ssbkeys = require('ssb-keys')

ssbkeys.create(path, function(err, k) {
  console.log(k) /* => {
    id: String,
    public: String,
    private: String
  }*/
})

ssbkeys.load(path, function(err, k) {
  console.log(k) /* => {
    id: String,
    public: String,
    private: String
  }*/
})

var k = ssbkeys.createSync(path)
console.log(k) /* => {
  id: String,
  public: String,
  private: String
}*/

var k = ssbkeys.loadSync(path)
console.log(k) /* => {
  id: String,
  public: String,
  private: String
}*/

var k = ssbkeys.generate()
console.log(k) /* => {
  id: String,
  public: String,
  private: String
}*/

var hash = ssbkeys.hash(new Buffer('deadbeef', 'hex'))
ssbkeys.isHash(hash) // => true

var sig = ssbkeys.sign(k, hash)
ssbkeys.verify(k.public, sig, hash) // => true

var secret = new Buffer('deadbeef', 'hex')
ssbkeys.hmac(secret, k.private) // => String

var obj = ssbkeys.signObj(k, { foo: 'bar' })
console.log(obj) /* => {
  foo: 'bar',
  signature: ...
} */
ssbkeys.verifyObj(k, obj) // => true

var secret = new Buffer('deadbeef', 'hex')
var obj = ssbkeys.signObjHmac(secret, { foo: 'bar' })
console.log(obj) /* => {
  foo: 'bar',
  hmac: ...
} */
ssbkeys.verifyObjHmac(secret, obj) // => true

var authRequest = ssbkeys.createAuth(k, 'client') // 'client' is default
console.log(authRequest) /* => {
  role: 'client',
  ts: Number,
  public: String,
  signature: ...
} */
```