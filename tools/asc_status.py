#!/usr/bin/env python3
"""Print where Lexify stands in App Store Connect, and who it is waiting on.

Run it yourself — it needs your vault, and no secret should pass through a
chat window:

    ! python3 tools/asc_status.py

Unlock the vault in your own shell first — this script never asks for a
password:

    export BW_SESSION=$(bw unlock --raw)
    python3 tools/asc_status.py

It reads the App Store Connect issuer id from the unlocked vault, signs a
short-lived read-only token with the .p8 key already on disk, and prints the
state of the app's versions and its most recent builds.

Nothing is written and nothing is stored: the token lives 10 minutes and only
GET requests are made.

If your vault item is named something else, pass the issuer id directly and
Bitwarden is skipped entirely:

    ! python3 tools/asc_status.py --issuer 69a6de7e-xxxx-xxxx-xxxx-xxxxxxxxxxxx
"""
import argparse
import base64
import json
import os
import pathlib
import re
import subprocess
import sys
import time
import urllib.error
import urllib.request

KEY_ID = "5YH964A9M4"
KEY_PATH = pathlib.Path.home() / "Documents" / "Apple Developer" / f"AuthKey_{KEY_ID}.p8"
BUNDLE_ID = "com.ol1n.duolingoCards"
API = "https://api.appstoreconnect.apple.com/v1"

# App Store Connect's vocabulary, sorted into "they owe us" and "we owe them".
APPLE_TURN = {
    "WAITING_FOR_REVIEW", "IN_REVIEW", "PENDING_APPLE_RELEASE",
    "PROCESSING_FOR_APP_STORE", "PENDING_CONTRACT", "READY_FOR_REVIEW",
}
YOUR_TURN = {
    "PREPARE_FOR_SUBMISSION", "DEVELOPER_REJECTED", "REJECTED",
    "METADATA_REJECTED", "INVALID_BINARY", "DEVELOPER_REMOVED_FROM_SALE",
    "REPLACED_WITH_NEW_VERSION",
}


def issuer_from_bitwarden():
    """Read the issuer id from an already-unlocked vault.

    This deliberately never prompts. Driving `bw`'s password prompt from
    inside a subprocess proved unreliable — it asked twice and rejected a
    pasted password — so unlocking stays where it belongs: your own shell.
    """
    session = os.environ.get("BW_SESSION")
    status = json.loads(subprocess.run(
        ["bw", "status"], capture_output=True, text=True).stdout or "{}")

    if not session and status.get("status") != "unlocked":
        raise SystemExit(
            "Bitwarden is locked, and this script will not prompt for your\n"
            "master password. Unlock it in your own shell first:\n\n"
            "    export BW_SESSION=$(bw unlock --raw)\n"
            "    python3 tools/asc_status.py\n\n"
            "Or skip the vault altogether — App Store Connect >\n"
            "Users and Access > Integrations > App Store Connect API, the\n"
            "Issuer ID is above the key list:\n\n"
            "    python3 tools/asc_status.py --issuer <uuid>")

    args = ["--session", session] if session else []
    r = subprocess.run(["bw", "list", "items", "--search", "appstore", *args],
                       capture_output=True, text=True)
    if r.returncode != 0:
        raise SystemExit(f"bw list failed: {r.stderr.strip()}")

    uuid = re.compile(r"\b[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-"
                      r"[0-9a-f]{4}-[0-9a-f]{12}\b", re.I)
    for item in json.loads(r.stdout or "[]"):
        for field in item.get("fields") or []:
            if "issuer" in (field.get("name") or "").lower():
                found = uuid.search(field.get("value") or "")
                if found:
                    print(f"issuer id from vault item: {item.get('name')}")
                    return found.group(0)
        blob = json.dumps(item)
        if "issuer" in blob.lower():
            found = uuid.search(blob)
            if found and found.group(0) != item.get("id"):
                print(f"issuer id from vault item: {item.get('name')}")
                return found.group(0)
    raise SystemExit(
        "No issuer id found in the vault items matching 'appstore'.\n"
        "Pass it directly:  python3 tools/asc_status.py --issuer <uuid>")


def der_to_raw(der: bytes) -> bytes:
    """ES256 signatures are DER from openssl; JWS wants raw r||s."""
    assert der[0] == 0x30
    i = 2 if der[1] < 0x80 else 3 + (der[1] & 0x7F) - 1
    out = b""
    for _ in range(2):
        assert der[i] == 0x02
        length = der[i + 1]
        val = der[i + 2:i + 2 + length].lstrip(b"\x00")
        out += val.rjust(32, b"\x00")
        i += 2 + length
    return out


def token(issuer: str) -> str:
    if not KEY_PATH.exists():
        raise SystemExit(f"private key not found: {KEY_PATH}")
    b64 = lambda b: base64.urlsafe_b64encode(b).rstrip(b"=")
    now = int(time.time())
    head = b64(json.dumps({"alg": "ES256", "kid": KEY_ID, "typ": "JWT"}).encode())
    body = b64(json.dumps({"iss": issuer, "iat": now, "exp": now + 600,
                           "aud": "appstoreconnect-v1"}).encode())
    signing_input = head + b"." + body
    der = subprocess.run(
        ["openssl", "dgst", "-sha256", "-sign", str(KEY_PATH)],
        input=signing_input, capture_output=True).stdout
    return (signing_input + b"." + b64(der_to_raw(der))).decode()


def get(path, jwt):
    req = urllib.request.Request(f"{API}/{path}",
                                 headers={"Authorization": f"Bearer {jwt}"})
    try:
        with urllib.request.urlopen(req, timeout=30) as r:
            return json.load(r)
    except urllib.error.HTTPError as e:
        detail = e.read().decode()[:400]
        raise SystemExit(f"App Store Connect returned {e.code}: {detail}")


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--issuer", help="skip Bitwarden and use this issuer id")
    args = ap.parse_args()

    issuer = args.issuer or issuer_from_bitwarden()
    jwt = token(issuer)

    apps = get(f"apps?filter[bundleId]={BUNDLE_ID}", jwt)["data"]
    if not apps:
        raise SystemExit(f"no app with bundle id {BUNDLE_ID}")
    app = apps[0]
    app_id = app["id"]
    print(f"\n{app['attributes']['name']}  ({BUNDLE_ID})\n")

    versions = get(f"apps/{app_id}/appStoreVersions?limit=5", jwt)["data"]
    print("Versions")
    verdicts = []
    for v in versions:
        a = v["attributes"]
        state = a.get("appStoreState") or a.get("appVersionState") or "?"
        whose = ("Apple" if state in APPLE_TURN
                 else "YOU" if state in YOUR_TURN else "?")
        verdicts.append((state, whose))
        print(f"  {a.get('versionString','?'):<10} {state:<32} waiting on: {whose}")

    builds = get(f"apps/{app_id}/builds?limit=5", jwt)["data"]
    print("\nBuilds")
    for b in builds:
        a = b["attributes"]
        print(f"  {a.get('version','?'):<6} {a.get('processingState','?'):<12}"
              f" expired={a.get('expired')}  uploaded={a.get('uploadedDate','?')[:19]}")

    print()
    if verdicts and verdicts[0][1] == "Apple":
        print("→ The newest version is with Apple. Nothing to do.")
    elif verdicts and verdicts[0][1] == "YOU":
        print("→ The newest version is waiting on YOU, not Apple.")
    else:
        print("→ State not recognised; read the version line above.")


if __name__ == "__main__":
    sys.exit(main())
