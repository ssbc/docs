## Installing and starting up your local Scuttlebot app

Scuttlebot is an application that you need to run in order to access the network.

1. Install Node.

2. Install the scuttlebot application globally: `npm install -g scuttlebot`

3. Start the scuttlebot server with: `sbot server`

4. Navigate your web browser to `http://localhost:8008/` and sign in with a new username.

## Connecting to a Pub Server

In order to connect to people outside of your local network (ie. the wider internet) you need to connect to a Pub server (it is basically just another Scuttlebot app running on a server). There is a list of Pub servers [here](Pub-Servers).

1. Ask someone that runs a Pub server for an invite (it is a big long code looking string with *blake2s* in it somewhere).

2. Open up your local Scuttlebot app in your browser: `http://localhost:8008/`

3. Click on the **Use an invite** link.

4. Paste in the invite code. ![use an invite link](http://i.imgur.com/4plwFLO.png)

5. It will tell you if it worked. If it did GREAT! You are now on the SSB network! If not then politely ask the Pub server maintainer if they know what's going on.