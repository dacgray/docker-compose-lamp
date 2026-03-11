#!/bin/bash

# Configuration
IMAGE_NAME="hospital-mysql-dev"
TAG="latest"
DUMP_FILE="dev-initdb-scrambled.sql"
DOCKERFILE="Mysql.Dev.Dockerfile"

echo "### Checking for scrambled dump file: $DUMP_FILE..."
if [ ! -f "$DUMP_FILE" ]; then
    echo "Error: $DUMP_FILE not found."
    echo "Please run the SQL scrambling script first:"
    echo "./generate-dev-dump.sh"
    exit 1
fi

echo "### Building dev database image: $IMAGE_NAME:$TAG..."

# Build the image
docker build -t "$IMAGE_NAME:$TAG" -f "$DOCKERFILE" .


if [ $? -eq 0 ]; then
    echo "### Build successful!"
    echo "### You can now run this image with:"
    echo "### docker run -d -p 3307:3306 --name dev-db $IMAGE_NAME:$TAG"
    echo ""
    echo "### Example: How to push this image to a registry"
    echo "### (Uncomment these lines in the script if needed)"
    echo "# REGISTRY=\"your-registry.example.com\""
    echo "# docker tag \"$IMAGE_NAME:$TAG\" \"\$REGISTRY/$IMAGE_NAME:$TAG\""
    echo "# docker push \"\$REGISTRY/$IMAGE_NAME:$TAG\""
else
    echo "### Error: Build failed."
    exit 1
fi
