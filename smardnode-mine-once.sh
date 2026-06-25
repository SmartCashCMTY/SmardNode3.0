#!/usr/bin/env bash
set -euo pipefail

CONF=/etc/smartcash3/smartcash.conf
DATADIR=/var/lib/smartcash3
CLI=/usr/local/bin/smartcash-cli
LOCK=/run/smartcash3/miner.lock
ENVFILE=/etc/smartcash3/miner.env
NODE_SERVICE=smardnode.service

install -d -m 0755 /run/smartcash3

if [[ -f "$ENVFILE" ]]; then
  source "$ENVFILE"
fi

PAYOUT_ADDRESS="${PAYOUT_ADDRESS:-}"
GENERATE_BLOCKS="${GENERATE_BLOCKS:-1}"
MAX_TRIES="${MAX_TRIES:-100000000}"
MIN_BLOCK_HEIGHT="${MIN_BLOCK_HEIGHT:-4269520}"
MIN_CONNECTIONS="${MIN_CONNECTIONS:-1}"
MINING_CPU_QUOTA="${MINING_CPU_QUOTA:-10%}"
cpu_quota_applied=0

if [[ -z "$PAYOUT_ADDRESS" ]]; then
  echo "PAYOUT_ADDRESS is required. Set it in $ENVFILE." >&2
  exit 1
fi

exec 9>"$LOCK"
flock -n 9 || exit 0

reset_cpu_quota() {
  if (( cpu_quota_applied )); then
    systemctl set-property --runtime "$NODE_SERVICE" CPUQuota=infinity >/dev/null 2>&1 || true
  fi
}

trap reset_cpu_quota EXIT

for _ in $(seq 1 60); do
  if "$CLI" -conf="$CONF" -datadir="$DATADIR" getblockcount >/dev/null 2>&1; then
    break
  fi
  sleep 2
done

height="$("$CLI" -conf="$CONF" -datadir="$DATADIR" getblockcount)"
if (( height < MIN_BLOCK_HEIGHT )); then
  echo "not mining: block height $height is below MIN_BLOCK_HEIGHT=$MIN_BLOCK_HEIGHT"
  exit 0
fi

connections="$("$CLI" -conf="$CONF" -datadir="$DATADIR" getconnectioncount)"
if (( connections < MIN_CONNECTIONS )); then
  echo "not mining: connection count $connections is below MIN_CONNECTIONS=$MIN_CONNECTIONS"
  exit 0
fi

systemctl set-property --runtime "$NODE_SERVICE" "CPUQuota=$MINING_CPU_QUOTA" >/dev/null
cpu_quota_applied=1
"$CLI" -conf="$CONF" -datadir="$DATADIR" generatetoaddress "$GENERATE_BLOCKS" "\"$PAYOUT_ADDRESS\"" "$MAX_TRIES"
