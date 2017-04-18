#!/bin/sh
set -ex
git checkout gh-pages
git merge master --no-commit
ssbc-sitegen docs
git commit -am build
