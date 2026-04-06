#!/usr/bin/env python3
"""
Script Name: hash_id.py
Description: Identifies the type of hash based on its characteristics
             (length, character set, known patterns).
Usage: python3 hash_id.py <hash>
Example:
    python3 hash_id.py 5f4dcc3b5aa765d61d8327deb882cf99
    python3 hash_id.py $2b$12$LJ3m4ys3Lj0lT/9u3Z1gCeWzFbSgHl6xKj0qLqZ8qE5qJ0qLqZ8qE
Disclaimer: For educational purposes only.
"""

import sys
import re


# Hash type definitions: (name, regex, min_len, max_len)
HASH_TYPES = [
    # MD5 variants
    ("MD5", r"^[a-fA-F0-9]{32}$", 32, 32),
    ("MD5 (Apache $apr1$)", r"^\$apr1\$[a-zA-Z0-9./]{8}\$[a-zA-Z0-9./]{22}$", 0, 0),
    ("MD5 (Unix)", r"^\$1\$[a-zA-Z0-9./]{8}\$[a-zA-Z0-9./]{22}$", 0, 0),

    # SHA variants
    ("SHA1", r"^[a-fA-F0-9]{40}$", 40, 40),
    ("SHA256", r"^[a-fA-F0-9]{64}$", 64, 64),
    ("SHA384", r"^[a-fA-F0-9]{96}$", 96, 96),
    ("SHA512", r"^[a-fA-F0-9]{128}$", 128, 128),
    ("SHA512 (Unix $6$)", r"^\$6\$[a-zA-Z0-9./]{8,16}\$[a-zA-Z0-9./]{86}$", 0, 0),

    # bcrypt
    ("bcrypt", r"^\$2[abxy]?\$\d{2}\$[./a-zA-Z0-9]{53}$", 0, 0),

    # NTLM
    ("NTLM", r"^[a-fA-F0-9]{32}$", 32, 32),

    # MySQL
    ("MySQL323", r"^[a-fA-F0-9]{16}$", 16, 16),
    ("MySQL SHA1", r"^\*[a-fA-F0-9]{40}$", 41, 41),

    # PostgreSQL
    ("PostgreSQL MD5", r"^md5[a-fA-F0-9]{32}$", 35, 35),

    # Cisco
    ("Cisco IOS SHA256", r"^\$8\$[a-zA-Z0-9./]{8}\$[a-zA-Z0-9./]{43}$", 0, 0),
    ("Cisco IOS SCRYPT", r"^\$9\$[a-zA-Z0-9./]{8}\$[a-zA-Z0-9./]{43}$", 0, 0),

    # JWT
    ("JWT (JSON Web Token)", r"^[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+$", 0, 0),

    # Base64
    ("Base64", r"^[A-Za-z0-9+/]{4,}={0,2}$", 0, 0),

    # CRC32
    ("CRC32", r"^[a-fA-F0-9]{8}$", 8, 8),

    # LM Hash
    ("LM Hash", r"^[a-fA-F0-9]{32}$", 32, 32),

    # Domain Cached Credentials
    ("MSSQL (2000)", r"^0x0100[a-fA-F0-9]{88}$", 0, 0),

    # Blake2
    ("BLAKE2b", r"^[a-fA-F0-9]{128}$", 128, 128),

    # Whirlpool
    ("Whirlpool", r"^[a-fA-F0-9]{128}$", 128, 128),
]


def identify_hash(hash_value):
    """Identify possible hash types for the given hash string."""
    matches = []

    for name, pattern, min_len, max_len in HASH_TYPES:
        # Check length constraints if specified
        if min_len and max_len:
            if not (min_len <= len(hash_value) <= max_len):
                continue

        # Check regex pattern
        if re.match(pattern, hash_value):
            matches.append(name)

    return matches


def main():
    if len(sys.argv) < 2:
        print("Usage: python3 hash_id.py <hash>")
        print("Example: python3 hash_id.py 5f4dcc3b5aa765d61d8327deb882cf99")
        sys.exit(1)

    hash_value = sys.argv[1].strip()

    if not hash_value:
        print("[!] Empty hash provided.")
        sys.exit(1)

    print(f"[*] Analyzing hash: {hash_value[:50]}{'...' if len(hash_value) > 50 else ''}")
    print(f"[*] Length: {len(hash_value)} characters")
    print("=" * 60)

    matches = identify_hash(hash_value)

    if matches:
        print(f"[+] Possible hash types ({len(matches)} match(es)):")
        for i, match in enumerate(matches, 1):
            print(f"    {i}. {match}")
    else:
        print("[!] No matching hash type found.")
        print("[i] This could be:")
        print("    - A custom or uncommon hash algorithm")
        print("    - An encrypted value (not a hash)")
        print("    - A hash with salt/pepper not included")

    print("=" * 60)


if __name__ == "__main__":
    main()
