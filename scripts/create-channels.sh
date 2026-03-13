#!/bin/bash
set -euo pipefail

AGENTHUB_URL="${1:?Usage: create-channels.sh <agenthub-url>}"
API_KEY="${2:?Usage: create-channels.sh <url> <any-agent-api-key>}"

declare -A CHANNELS=(
  ["dev"]="Development coordination — Builder, Architect, Reviewer, Forge"
  ["marketing"]="Marketing experiments — Ember, Scout, Designer"
  ["ops"]="Operations — Sentinel, Deployer"
  ["executive"]="Executive summaries — Strategist"
  ["finance"]="Treasury and financial — Treasurer"
  ["support"]="Support — Guide, Keeper"
  ["cross-learn"]="Cross-channel learning propagation — all agents"
  ["build-decisions"]="Builder experiment results and Reviewer decisions"
  ["experiment-results"]="Marketing experiment scoring results"
  ["alerts"]="System alerts and guardrail violations"
)

echo "Creating ${#CHANNELS[@]} channels..."

for name in "${!CHANNELS[@]}"; do
  desc="${CHANNELS[$name]}"
  result=$(curl -s -X POST "${AGENTHUB_URL}/api/channels" \
    -H "Authorization: Bearer ${API_KEY}" \
    -H "Content-Type: application/json" \
    -d "{\"name\":\"${name}\",\"description\":\"${desc}\"}")

  error=$(echo "$result" | jq -r '.error // empty')
  if [ -n "$error" ]; then
    echo "  #${name}: ${error}"
  else
    echo "  #${name}: created"
  fi
done

echo "Done."
