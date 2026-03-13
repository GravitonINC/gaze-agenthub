#!/bin/bash
set -euo pipefail

AGENTHUB_URL="${1:?Usage: register-agents.sh <agenthub-url>}"
ADMIN_KEY="${AGENTHUB_ADMIN_KEY:?Set AGENTHUB_ADMIN_KEY}"

AGENTS=(
  strategist builder worker-1 worker-2 worker-3 reviewer deployer
  architect designer ember scout sentinel forge guide keeper treasurer
)

echo "Registering ${#AGENTS[@]} agents..."

declare -A KEYS=()

for agent in "${AGENTS[@]}"; do
  result=$(curl -s -X POST "${AGENTHUB_URL}/api/admin/agents" \
    -H "Authorization: Bearer ${ADMIN_KEY}" \
    -H "Content-Type: application/json" \
    -d "{\"id\":\"${agent}\"}")

  api_key=$(echo "$result" | jq -r '.api_key // empty')

  if [ -n "$api_key" ]; then
    echo "  ${agent}: registered"
    KEYS["$agent"]="$api_key"
  else
    error=$(echo "$result" | jq -r '.error // "unknown error"')
    echo "  ${agent}: ${error}"
  fi
done

# Build JSON object of all keys
JSON="{"
first=true
for agent in "${!KEYS[@]}"; do
  if [ "$first" = true ]; then
    first=false
  else
    JSON+=","
  fi
  JSON+="\"${agent}\":\"${KEYS[$agent]}\""
done
JSON+="}"

echo ""
echo "Agent keys JSON (store in Secrets Manager):"
echo "$JSON" | jq .

# Optionally store directly
if [ "${STORE_KEYS:-false}" = "true" ]; then
  aws secretsmanager put-secret-value \
    --secret-id gaze-agents/agenthub-agent-keys \
    --secret-string "$JSON" \
    --region us-east-1
  echo "Stored keys in gaze-agents/agenthub-agent-keys"
fi
