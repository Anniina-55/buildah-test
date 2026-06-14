#!/bin/bash

set -e

IMAGE_NAME="scratch-static-web"

echo "Creating scratch container with Buildah..."

ctr=$(buildah from scratch)

echo "Mounting container filesystem..."
mnt=$(buildah mount $ctr)

echo "Creating web directory..."
mkdir -p $mnt/www

echo "Copying files..."
cp index.html $mnt/www/
cp containers.png $mnt/www/

echo "Configuring container..."
buildah config --cmd 'busybox httpd -f -p 8080 -h /www' $ctr

echo "Committing image..."
buildah commit $ctr $IMAGE_NAME

echo "Done -> container image is committed!"
buildah images
