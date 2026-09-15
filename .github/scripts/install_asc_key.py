#!/usr/bin/env python3
import os
import sys
import base64

raw = os.environ.get("APP_STORE_CONNECT_PRIVATE_KEY", "").strip()
key_id = os.environ.get("APP_STORE_CONNECT_KEY_ID", "").strip()

if not raw or not key_id:
    print("Missing APP_STORE_CONNECT_PRIVATE_KEY or APP_STORE_CONNECT_KEY_ID")
    sys.exit(1)

# Handle potential Base64 wrapping
try:
    if not raw.startswith("-----BEGIN"):
        decoded = base64.b64decode(raw).decode("utf-8")
        if "BEGIN PRIVATE KEY" in decoded:
            raw = decoded
except Exception:
    pass

# Normalize CRLF -> LF and strip blank lines
lines = [line.strip() for line in raw.replace("\r\n", "\n").replace("\r", "\n").split("\n") if line.strip()]

# Ensure header and footer
if not any("BEGIN PRIVATE KEY" in l for l in lines):
    lines.insert(0, "-----BEGIN PRIVATE KEY-----")
if not any("END PRIVATE KEY" in l for l in lines):
    lines.append("-----END PRIVATE KEY-----")

clean_key = "\n".join(lines) + "\n"

targets = [
    os.path.expanduser(f"~/.appstoreconnect/private_keys/AuthKey_{key_id}.p8"),
    os.path.expanduser(f"~/.private_keys/AuthKey_{key_id}.p8"),
]
for p in targets:
    os.makedirs(os.path.dirname(p), exist_ok=True)
    with open(p, "w", newline="\n") as f:
        f.write(clean_key)
    os.chmod(p, 0o600)
    print(f"Successfully installed key to {p} ({len(clean_key)} bytes)")
