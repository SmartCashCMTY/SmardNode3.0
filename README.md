# SmardNode 3.0.0

SmartCash 3.0.0 SmardNode for Ubuntu Server 24.04 LTS.

## What It Does

SmardNode 3.0 runs the SmartCash daemon with full SmartNode capabilities,
SAPI for light wallets, and a built-in CPU block producer.

## Quick Start

```bash
curl -fsSLO https://raw.githubusercontent.com/SmartCashCMTY/SmardNode3.0/main/smardnode-install.sh
chmod +x smardnode-install.sh
sudo SMARTNODE_PRIVKEY="YOUR_SMARTNODE_PRIVKEY" \
     SMARTNODE_WALLET_ADDRESS="YOUR_WALLET_ADDRESS" \
     bash smardnode-install.sh
```

## System Requirements

- Ubuntu Server 24.04 LTS
- Public IPv4 address
- 2 vCPU (recommended: 4 vCPU)
- 4 GB RAM (recommended: 8 GB RAM)
- 30 GB SSD (recommended: 120 GB NVMe)
- 100,000 SMART collateral (on controller wallet)

## Installation

### Prerequisites

1. Generate the SmartNode private key on your controller wallet:
   ```
   smartcash-cli smartnode genkey
   ```

2. Have a SmartCash wallet address ready for the SmardNode.

### Run the Installer

```bash
sudo SMARTNODE_PRIVKEY="YOUR_GENERATED_KEY" \
     SMARTNODE_WALLET_ADDRESS="Sxxxxxxxxxxxxxxxx" \
     bash smardnode-install.sh
```

The installer will:
- Install the SmartCash 3.0.0 daemon
- Configure the SmardNode with SmartNode and SAPI
- Create systemd services
- Set up the firewall and security
- Start all services automatically

## Configuration

| File | Purpose |
|------|---------|
| `/etc/smartcash3/smartcash.conf` | Daemon configuration |
| `/etc/smartcash3/miner.env` | Block producer configuration |

### smartcash.conf (key settings)

```
smartnode=1                                      # SmartNode enabled
smartnodeprivkey=YOUR_PRIVKEY                    # SmartNode identity key
smartnodewallet=Sxxxxxxxxxxxxxxxx                # SmardNode wallet address
sapi=1                                           # SAPI for light wallets
sapiport=28080                                   # SAPI port
```

### miner.env

```
PAYOUT_ADDRESS=Sxxxxxxxxxxxxxxxx                 # Block reward payout address
MINING_CPU_QUOTA=10%                             # CPU throttling
```

## Services

| Service | Description |
|---------|-------------|
| `smardnode.service` | Main daemon (SmartNode, full node) |
| `smardnode-miner.service` | Block producer (oneshot) |
| `smardnode-miner.timer` | Block producer timer (every 55 seconds) |

### Service Commands

```bash
systemctl status smardnode --no-pager
systemctl status smardnode-miner.timer --no-pager
journalctl -u smardnode -f
journalctl -u smardnode-miner -f
```

## Useful CLI Commands

```bash
smartcash-cli -conf=/etc/smartcash3/smartcash.conf -datadir=/var/lib/smartcash3 getinfo
smartcash-cli -conf=/etc/smartcash3/smartcash.conf -datadir=/var/lib/smartcash3 getconnectioncount
smartcash-cli -conf=/etc/smartcash3/smartcash.conf -datadir=/var/lib/smartcash3 getblockcount
smartcash-cli -conf=/etc/smartcash3/smartcash.conf -datadir=/var/lib/smartcash3 smartnode status
```

## Ports

| Port | Protocol | Direction | Purpose |
|------|----------|-----------|---------|
| 29678 | TCP | IN/OUT | P2P network |
| 29679 | TCP | LOCAL | RPC (127.0.0.1) |
| 28080 | TCP | IN | SAPI API |

## Update

```bash
wget -O smardnode-install.sh https://raw.githubusercontent.com/SmartCashCMTY/SmardNode3.0/main/smardnode-install.sh
sudo SMARTNODE_PRIVKEY="..." SMARTNODE_WALLET_ADDRESS="S..." bash smardnode-install.sh
```

## Backup

- `/etc/smartcash3/smartcash.conf`
- `/etc/smartcash3/miner.env`
- Controller-side: `smartnode.conf`

## Security

Automatic security updates can be enabled with:

```bash
sudo bash auto-updates-setup.sh
```

This configures unattended-upgrades every 14 days with automatic reboot at 03:00 if needed.

- Never commit secrets, seed phrases, or private keys to Git
- Keep wallet data and configuration outside of Git
- Use a dedicated system user and restrictive file permissions
- Run the controller wallet on a separate machine from the VPS

## Credits

Original SmartCash Project: https://github.com/smartcash
This repository is an update 3.0.0 based on the open-source work of the SmartCash project.
All rights to original components, trademarks, logos, source code, and documentation remain
with their respective owners.

## License

SmartCash Core is released under the MIT License.
See https://github.com/SmartCashCMTY/Core-Source-Repo for the full license text.
No third-party software is bundled in this repository.

## Disclaimer

This software is provided "as is", without warranty of any kind, express or implied.
Use at your own risk. The authors and contributors assume no liability for:
- Direct or indirect damages
- Data loss or corruption
- Financial losses
- Loss of access to wallets or private keys
- Misconfiguration or operator error
- Network or blockchain issues
- Software bugs or security vulnerabilities

## Cryptocurrency Risks

Cryptocurrencies involve substantial risk of loss and are not suitable for all investors.
- The value of digital assets can be highly volatile and may result in total loss
- Node operation, staking, and mining carry technical and financial risks
- You are solely responsible for securing your wallets and private keys
- You are responsible for compliance with local laws and tax obligations

## Legal Notice

Use of this software must comply with all applicable local, national, and international
laws and regulations. No legal, tax, or financial advice is provided.
