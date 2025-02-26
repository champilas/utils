#!/bin/bash

# This script will prune unused Docker objects

# Prune containers
echo "Pruning containers..."
docker container prune -f

# Prune images
echo "Pruning images..."
docker image prune -a -f

# Prune networks
echo "Pruning networks..."
docker network prune -f

# Prune builder cache
echo "Pruning builder cache..."
docker builder prune -f

echo "Docker cleanup complete."
