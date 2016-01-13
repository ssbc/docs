#!/bin/bash

GITHUB_ROOT="https://raw.githubusercontent.com" #todo get this right
DEFAULT_ORG="ssbc"

function fetch() {
  REPO=$1
  FILE=$2
  OUT=$3
  ORG=$4
  if [ -z $ORG ]; then
    ORG=$DEFAULT_ORG
  fi
  LOCAL_PATH="$HOME/${REPO}/${FILE}"
  GH_URL="${GITHUB_ROOT}/${ORG}/${REPO}/master/$FILE"
  if [ -f $LOCAL_PATH ]; then
    echo "Copying $LOCAL_PATH to $OUT"
    cp $LOCAL_PATH $OUT
  else
    echo "CURLing $REMOTE_PATH to $OUT"
    curl -o $OUT $GH_URL
  fi
}

fetch scuttlebot api.md ./api/scuttlebot.md
fetch scuttlebot plugins/blobs.md ./api/scuttlebot-blobs.md
fetch scuttlebot plugins/block.md ./api/scuttlebot-block.md
fetch scuttlebot plugins/friends.md ./api/scuttlebot-friends.md
fetch scuttlebot plugins/gossip.md ./api/scuttlebot-gossip.md
fetch scuttlebot plugins/invite.md ./api/scuttlebot-invite.md
fetch scuttlebot plugins/replicate.md ./api/scuttlebot-replicate.md
fetch ssb-msgs README.md ./api/ssb-msgs.md
fetch ssb-msg-schemas README.md ./api/ssb-msg-schemas.md
fetch ssb-ref README.md ./api/ssb-ref.md
fetch ssb-keys README.md ./api/ssb-keys.md
fetch ssb-config README.md ./api/ssb-config.md
fetch secret-stack README.md ./api/secret-stack.md
fetch muxrpc README.md ./api/muxrpc.md
fetch pull-stream README.md ./api/pull-stream.md dominictarr