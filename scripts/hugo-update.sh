#!/bin/bash
HUGO_DIR=/tmp/hugo
rm -r "$HUGO_DIR"
mkdir "$HUGO_DIR"
cd "$HUGO_DIR"
git clone https://github.com/fruworg/fruworg.github.io --recurse-submodules -j8 .
hugo -s /tmp/hugo --destination /var/caddy/hugo
rm -r "$HUGO_DIR"
