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

echo "Downloading Caddy binary..."
curl -L -o $mnt/bin/caddy \
https://github.com/caddyserver/caddy/releases/latest/download/caddy_linux_amd64

chmod +x $mnt/bin/caddy

echo "Configuring container..."
buildah config \
  --env PATH=/bin \
  --cmd "/bin/caddy file-server --root /www --listen :8080" \
  $ctr

echo "Committing image..."
buildah commit $ctr $IMAGE_NAME

echo "Done!"
