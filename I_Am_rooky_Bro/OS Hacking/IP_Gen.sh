#!/bin/bash
echo "[*] Setting up the victim machine, please wait..."

# Detect the first Ethernet interface dynamically
IFACE=$(ip -o link show | awk -F': ' '{print $2}' | grep -E '^e' | head -n1)

if [ -z "$IFACE" ]; then
    echo "[!] No network interface found. Exiting."
    exit 1
fi

# Generate a random host IP between 1 and 254 (avoid .0 and .255)
RAND_IP=$(( (RANDOM % 254) + 1 ))

# Reset and assign new IP
ip link set "$IFACE" down
ip addr flush dev "$IFACE"
ip addr add "172.16.45.$RAND_IP/24" dev "$IFACE"
ip link set "$IFACE" up

# Optional: start services (comment/uncomment as needed)
# systemctl start ssh
# systemctl start apache2
# systemctl start tftpd-hpa   # On Debian/Ubuntu, service is often named tftpd-hpa

echo "[*] Victim machine is now setup."
echo "[*] Network interface: $IFACE"
echo "[*] Assigned IP: 172.16.45.$RAND_IP"
echo "[*] The victim is somewhere in the 172.16.45.0/24 subnet."
echo "[*] You may now close this window and begin your attack... Good luck!"
