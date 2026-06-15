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

echo "Adding busybox binary..."
cp /bin/busybox $mnt/bin/

echo "Setting permissions..."
chmod +x $mnt/bin/busybox

echo "Configuring container..."
buildah config --cmd "/bin/busybox httpd -f -p 8080 -h /www" $ctr

echo "Committing image..."
buildah commit $ctr $IMAGE_NAME

echo "Done!"
