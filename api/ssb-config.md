# ssb-config

Configuration module used by [`scuttlebot`](https://github.com/ssbc/scuttlebot).

## Configuration

* `host` *(string)* The domain or ip address for `sbot`. Defaults to your public ip address.
* `port` *(string|number)* The port for `sbot`. Defaults to `8008`.
* `timeout`: *(number)* Number of milliseconds a replication stream can idle before it's automatically disconnected. Defaults to `30000`.
* `pub` *(boolean)* Replicate with pub servers. Defaults to `true`.
* `local` *(boolean)* Replicate with local servers found on the same network via `udp`. Defaults to `true`.
* `phoenix` *(boolean)* Use the local ui [`Phoenix`](https://github.com/ssbc/phoenix). Defaults to `true`.
* `friends.dunbar` *(number)* [`Dunbar's number`](https://en.wikipedia.org/wiki/Dunbar%27s_number). Number of nodes your instance will replicate. Defaults to `150`.
* `friends.hops` *(number)* How many friend of friend hops to replicate. Defaults to `3`.
* `gossip.connections` *(number)* How many other nodes to connect with at one time. Defaults to `2`.
* `path` *(string)* Path to the application data folder, which contains the private key, message attachment data (blobs) and the leveldb backend. Defaults to `$HOME/.ssb`.

There are some configuration options for the sysadmins out there. All configuration is loaded via [`rc`](https://github.com/dominictarr/rc). You can pass any configuration value in as cli arg, env var, or in a file.

## License

MIT
