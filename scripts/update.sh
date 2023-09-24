#!/bin/bash

source /root/.bashrc

# Iterate through all folders in /opt
for FOLDER in /opt/*; do
  if [ -d "$FOLDER" ]; then
    echo "Processing folder: $FOLDER"

    # Navigate into the folder
    cd "$FOLDER" || continue

    # Pull Docker Compose images
    docker compose pull

    # Bring up Docker Compose services in detached mode
    docker compose up -d

    # Return to the previous directory
    cd -
  fi
done

docker system prune -a -f
