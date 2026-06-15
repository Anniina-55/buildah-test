#!/bin/bash
set -e

IMAGE_NAME="scratch-static-web"

echo "Creating scratch container..."

ctr=$(buildah from scratch)
mnt=$(buildah mount $ctr)

echo "Creating filesystem structure..."
mkdir -p $mnt/www
mkdir -p $mnt/bin

echo "Copying static files..."
cp index.html $mnt/www/
cp containers.png $mnt/www/

echo "Downloading busybox (static binary)..."
curl -L -o $mnt/bin/busybox https://busybox.net/downloads/binaries/1.36.1-x86_64-linux-musl/busybox

chmod +x $mnt/bin/busybox

echo "Configuring container..."
buildah config \
  --env PATH=/bin \
  --cmd "/bin/busybox httpd -f -p 8082 -h /www" \
  $ctr

echo "Committing image..."
buildah commit $ctr $IMAGE_NAME

echo "Done!"
