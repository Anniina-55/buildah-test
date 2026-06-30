#!/usr/bin/env bash
set -e

# Define registry you use
echo "Select registry:"
echo "1) GitHub Container Registry (ghcr.io)"
echo "2) Docker Hub (docker.io)"
read -p "Choice (1/2): " REG_CHOICE

# Give your username and make sure it's in lowercase
read -p "Registry username: " USER
USER=$(echo "$USER" | tr '[:upper:]' '[:lower:]')

# Name your image and give tag
echo "Set image name"
read -p "Image name: " IMAGE_NAME

echo "Set tag (default: latest)"
read -p "Tag: " TAG

TAG=${TAG:-latest}

case "$REG_CHOICE" in
  1)
    REGISTRY="ghcr.io"
    ;;
  2)
    REGISTRY="docker.io"
    ;;
  *)
    echo "Invalid choice"
    exit 1
    ;;
esac

FULL_IMAGE="$REGISTRY/$USER/$IMAGE_NAME:$TAG"

echo "Building image: $FULL_IMAGE"

# Create container
newcontainer=$(buildah from scratch)

# Mount + modify container filesystem (must run inside unshare)
buildah unshare bash -c "

scratchmount=\$(buildah mount $newcontainer)

echo 'Mounted at:' \$scratchmount

mkdir -p \$scratchmount/www
mkdir -p \$scratchmount/bin

# Copy static files (supports HTML + JS + CSS etc.)
cp -r www/* \$scratchmount/www/

# Build server binary and copy it (assuming Go is installed on host or available during build)
echo 'Building Go binary...'
GOOS=linux GOARCH=amd64 CGO_ENABLED=0 go build -o server main.go
cp server \$scratchmount/bin/server
chmod +x \$scratchmount/bin/server

exit
"

# runtime command
buildah config --cmd "/bin/server" "$newcontainer"

echo "Committing image..."
buildah commit "$newcontainer" "$IMAGE_NAME"

echo "Tagging image..."
buildah tag "$IMAGE_NAME" "$FULL_IMAGE"

echo "Login to $REGISTRY..."
if buildah login "$REGISTRY" --get-login >/dev/null 2>&1; then
  echo "Credential helper active or already logged in..."
else
  read -p "Username: " USER
  USER=$(echo "$USER" | tr '[:upper:]' '[:lower:]')

  read -s -p "Password / Token: " REG_PASS
  echo

  echo "$REG_PASS" | buildah login "$REGISTRY" -u "$USER" --password-stdin
fi

echo "Pushing image..."
buildah push "$FULL_IMAGE"

echo "Done: $FULL_IMAGE"
buildah images | grep "$IMAGE_NAME"
