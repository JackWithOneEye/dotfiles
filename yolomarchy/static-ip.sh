#!/usr/bin/env bash

set -euo pipefail

usage() {
  echo "Usage: $0 <ip-address[/cidr]>"
  echo "  IP example: 192.168.1.100/24  (/24 assumed if omitted)"
  exit 1
}
[[ $# -lt 1 ]] && usage
IP_CIDR="$1"
# If no CIDR suffix, append /24
[[ "$IP_CIDR" != */* ]] && IP_CIDR="${IP_CIDR}/24"
# Derive gateway from IP
BASE="${IP_CIDR%.*}"
GATEWAY="${BASE}.1"

NETFILE="/etc/systemd/network/10-${IFACE}.network"
echo "Configuring static IP on $IFACE:"
echo "  Address:  $IP_CIDR"
echo "  Gateway:  $GATEWAY"
echo "  File:     $NETFILE"
# Use an exact-match so we don't accidentally touch other interfaces
sudo tee "$NETFILE" >/dev/null <<EOF
[Match]
Name=$IFACE

[Link]
RequiredForOnline=routable

[Network]
Address=$IP_CIDR
Gateway=$GATEWAY
MulticastDNS=yes
EOF
sudo systemctl restart systemd-networkd
echo "Done. Current address:"
ip -4 addr show "$IFACE" | grep inet
