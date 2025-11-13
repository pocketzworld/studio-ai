#!/bin/bash

if [ ! -d '/tmp/creator-docs' ]; then
  git clone https://github.com/pocketzworld/creator-docs.git /tmp/creator-docs
fi

git -C /tmp/creator-docs pull