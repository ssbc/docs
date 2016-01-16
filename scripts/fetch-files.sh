#!/bin/bash

GITHUB_ROOT="https://raw.githubusercontent.com"
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

  # try to copy locally first, then fallback to fetching from github
  if [ -f $LOCAL_PATH ]; then
    echo "Copying $LOCAL_PATH to $OUT"
    cp $LOCAL_PATH $OUT
  else
    echo "CURLing $REMOTE_PATH to $OUT"
    curl -o $OUT $GH_URL
  fi
}

fetch pull-stream     README.md             ./api/pull-stream.md dominictarr