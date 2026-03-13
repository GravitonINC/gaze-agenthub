#!/bin/bash
set -euo pipefail

ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
REGION=us-east-1
REPO="${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/gaze-agenthub"

aws ecr get-login-password --region "$REGION" | docker login --username AWS --password-stdin "${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com"
docker build -t gaze-agenthub .
docker tag gaze-agenthub:latest "${REPO}:latest"
docker push "${REPO}:latest"

echo "Pushed ${REPO}:latest"
