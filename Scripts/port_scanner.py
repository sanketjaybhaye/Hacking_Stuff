#!/usr/bin/env python3
"""
Script Name: port_scanner.py
Description: Fast TCP port scanner with basic service detection.
             Uses concurrent connections for speed.
Usage: python3 port_scanner.py <target> [port_range]
Example:
    python3 port_scanner.py 192.168.1.1
    python3 port_scanner.py example.com 1-1000
    python3 port_scanner.py 10.0.0.0/24 80,443,8080
Disclaimer: Only use on systems you own or have explicit permission to test.
"""

import sys
import socket
import argparse
from concurrent.futures import ThreadPoolExecutor, as_completed
from datetime import datetime


# Common ports with service names
COMMON_SERVICES = {
    21: "FTP", 22: "SSH", 23: "Telnet", 25: "SMTP", 53: "DNS",
    80: "HTTP", 110: "POP3", 143: "IMAP", 443: "HTTPS", 445: "SMB",
    993: "IMAPS", 995: "POP3S", 3306: "MySQL", 3389: "RDP",
    5432: "PostgreSQL", 5900: "VNC", 6379: "Redis", 8080: "HTTP-Proxy",
    8443: "HTTPS-Alt", 27017: "MongoDB"
}


def scan_port(target, port, timeout=1):
    """Scan a single port and return result."""
    try:
        sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        sock.settimeout(timeout)
        result = sock.connect_ex((target, port))
        sock.close()

        if result == 0:
            service = COMMON_SERVICES.get(port, "Unknown")
            return {"port": port, "status": "open", "service": service}
    except (socket.timeout, socket.error):
        pass

    return {"port": port, "status": "closed", "service": ""}


def parse_ports(port_arg):
    """Parse port argument into a list of ports."""
    ports = []
    try:
        for part in port_arg.split(","):
            if "-" in part:
                start, end = map(int, part.split("-"))
                ports.extend(range(start, end + 1))
            else:
                ports.append(int(part))
    except ValueError:
        print(f"[!] Invalid port specification: {port_arg}")
        sys.exit(1)

    return sorted(set(ports))


def main():
    parser = argparse.ArgumentParser(
        description="Fast TCP Port Scanner with Service Detection"
    )
    parser.add_argument("target", help="Target IP, domain, or CIDR range")
    parser.add_argument(
        "ports",
        nargs="?",
        default="1-1024",
        help="Port range (e.g., 1-1024, 80,443,8080). Default: 1-1024",
    )
    parser.add_argument(
        "-t", "--threads", type=int, default=100, help="Number of concurrent threads (default: 100)"
    )
    parser.add_argument(
        "--timeout", type=int, default=1, help="Connection timeout in seconds (default: 1)"
    )

    args = parser.parse_args()

    target = args.target
    ports = parse_ports(args.ports)
    max_threads = args.threads
    timeout = args.timeout

    print(f"[*] Port Scanner started at {datetime.now()}")
    print(f"[*] Target: {target}")
    print(f"[*] Scanning {len(ports)} ports")
    print(f"[*] Threads: {max_threads} | Timeout: {timeout}s")
    print("=" * 60)

    open_ports = []

    try:
        with ThreadPoolExecutor(max_workers=max_threads) as executor:
            future_to_port = {
                executor.submit(scan_port, target, port, timeout): port
                for port in ports
            }

            for future in as_completed(future_to_port):
                result = future.result()
                if result["status"] == "open":
                    open_ports.append(result)
                    print(
                        f"[+] Port {result['port']:5d}/tcp  OPEN  - {result['service']}"
                    )

    except KeyboardInterrupt:
        print("\n[!] Scan interrupted by user.")
        sys.exit(0)
    except Exception as e:
        print(f"[!] Error: {e}")
        sys.exit(1)

    print("=" * 60)
    print(f"[*] Scan complete. {len(open_ports)} open ports found.")
    print(f"[*] Finished at {datetime.now()}")

    if open_ports:
        print("\n[*] Summary of open ports:")
        for p in sorted(open_ports, key=lambda x: x["port"]):
            print(f"    {p['port']:5d}/tcp  {p['service']}")


if __name__ == "__main__":
    main()
