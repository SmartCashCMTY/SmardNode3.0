# SmardNode 3.0.0 - Installation Guide

## Architecture

```
┌────────────────────────────┐
│     Controller Wallet      │
│  (100,000 SMART Collateral)│
│  smartnode.conf            │
└────────────┬───────────────┘
             │ broadcast
             ▼
┌────────────────────────────────────────────────┐
│              SmardNode VPS                     │
│         (Ubuntu Server 24.04 LTS)              │
│                                                │
│  smardnode.service                             │
│  ┌─────────────────────────────────────────┐  │
│  │           smartcashd (v3.0.0)            │  │
│  │  • smartnode=1                          │  │
│  │  • sapi=1                               │  │
│  │  • port 29678 (P2P)                     │  │
│  │  • rpcport 29679 (localhost)            │  │
│  │  • sapiport 28080                       │  │
│  │  • smartnodeprivkey=xxx                 │  │
│  │  • smartnodewallet=Sxxx                 │  │
│  └─────────────────────────────────────────┘  │
│                                                │
│  smardnode-miner.timer (55s)                   │
│  ┌─────────────────────────────────────────┐  │
│  │  smardnode-mine-once.sh                  │  │
│  │  • CPU quota: 10%                       │  │
│  │  • Payout: wallet address               │  │
│  └─────────────────────────────────────────┘  │
│                                                │
│  /etc/smartcash3/smartcash.conf                │
│  /etc/smartcash3/miner.env                     │
│  /var/lib/smartcash3/ (blockchain data)        │
│                                                │
│  Ports:                                        │
│  • 29678/tcp → P2P (public)                    │
│  • 28080/tcp → SAPI (public)                   │
│  • 29679/tcp → RPC (127.0.0.1)                 │
└────────────────────────────────────────────────┘
```

## Wallet Address

During installation you enter your SmardNode wallet address once.
This address is stored in the daemon configuration and used for block rewards.

```
Installation:
├── Input: SMARTNODE_WALLET_ADDRESS (once)
│
Result:
├── smartcash.conf:   smartnodewallet=S...
└── miner.env:        PAYOUT_ADDRESS=S...
```

## Step-by-Step Installation

### 1. Prepare the Controller Wallet

On your controller wallet (separate machine holding 100,000 SMART collateral):

```bash
smartcash-cli smartnode genkey
```

Save the generated key. This is your SMARTNODE_PRIVKEY.

### 2. Have Your Wallet Address Ready

A SmartCash wallet address for the SmardNode.

### 3. Install SmardNode

```bash
wget https://raw.githubusercontent.com/SmartCashCMTY/SmardNode3.0/main/smardnode-install.sh
chmod +x smardnode-install.sh
sudo SMARTNODE_PRIVKEY="YOUR_GENERATED_KEY" \
     SMARTNODE_WALLET_ADDRESS="Sxxxxxxxxxxxxxxxx" \
     bash smardnode-install.sh
```

### 4. Configure the Controller

On your controller wallet, create or edit `smartnode.conf`:

```
SmardNode01 VPS_IP_ADDRESS:29678 YOUR_GENERATED_KEY COLLATERAL_TXID COLLATERAL_OUTPUT_INDEX
```

Then start the SmartNode:

```bash
smartcash-cli smartnode start-alias SmardNode01
```

## Troubleshooting

### SmartNode status shows "WAITING_FOR_START"

Check:
- `smartcash-cli smartnode status`
- Controller has run `smartnode start-alias`
- Collateral is exactly 100,000 SMART
- VPS IP is correct in `smartnode.conf`
- Port 29678 is open: `ufw status`

### Block producer not running

Check:
- `journalctl -u smardnode-miner -f`
- Block height: `smartcash-cli getblockcount` (must be > MIN_BLOCK_HEIGHT)
- Connections: `smartcash-cli getconnectioncount` (must be >= MIN_CONNECTIONS)
- Payout address: `cat /etc/smartcash3/miner.env`

### Service not starting

```bash
journalctl -u smardnode -f
systemctl status smardnode --no-pager
```

## Maintenance

### Restart Services

```bash
systemctl restart smardnode
systemctl restart smardnode-miner.timer
```

### View Logs

```bash
journalctl -u smardnode -f
journalctl -u smardnode-miner -f
```

### Blockchain Status

```bash
smartcash-cli -conf=/etc/smartcash3/smartcash.conf -datadir=/var/lib/smartcash3 getinfo
```

### Backup

```bash
cp /etc/smartcash3/smartcash.conf /root/backup/
cp /etc/smartcash3/miner.env /root/backup/
```
