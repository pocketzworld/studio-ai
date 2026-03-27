#!/usr/bin/env python3
"""
Highrise Studio Asset Catalog CLI.

A read-only API client for browsing the Highrise Studio Asset Catalog.
Auth credentials must be provided via --auth-file (from the .catalog trigger)
or --token/--base-url flags.

Installation is handled by the .install trigger, not this script.

Usage:
    python catalog.py --auth-file path/to/catalog_result.json list
    python catalog.py --token "hr_s_xxx=yyy" --base-url "https://production-create.highrise.game/api" get <id>
"""

import argparse
import json
import sys
import urllib.error
import urllib.parse
import urllib.request

VALID_CATEGORIES = [
    "structure", "landscape", "furniture", "light", "vehicle",
    "clothing", "creatures", "dev_modules", "materials",
    "templates", "vfx", "animations", "gui", "props",
]

ASSETS_PATH = "/world_builder_assets"


def _api_get(base_url, path, token):
    url = base_url + path
    req = urllib.request.Request(url, method="GET")
    req.add_header("Cookie", token)
    req.add_header("User-Agent", "HighriseStudio-CatalogCLI/1.0")

    try:
        with urllib.request.urlopen(req) as resp:
            raw = resp.read().decode("utf-8")
            if not raw:
                return None
            return json.loads(raw)
    except urllib.error.HTTPError as e:
        if e.code == 401:
            print("Error: Session expired or invalid. Re-run the .catalog trigger.", file=sys.stderr)
            sys.exit(1)
        body_text = e.read().decode("utf-8", errors="replace")
        print(f"Error: HTTP {e.code} — {body_text}", file=sys.stderr)
        sys.exit(1)


# ── Subcommands ──────────────────────────────────────────────────────────────

def cmd_list(args, base_url, token):
    params = {"status": "published", "page": str(args.page)}
    if args.category:
        params["category"] = args.category
    if args.search:
        params["query"] = args.search
    if args.bundle is not None:
        params["is_bundle"] = str(args.bundle).lower()
    if args.free:
        params["max_price"] = "0"
    if args.has_scripts:
        params["has_scripts"] = "true"

    qs = urllib.parse.urlencode(params)
    data = _api_get(base_url, f"{ASSETS_PATH}?{qs}", token)
    print(json.dumps(data, indent=2))


def cmd_get(args, base_url, token):
    data = _api_get(base_url, f"{ASSETS_PATH}/{args.id}", token)
    print(json.dumps(data, indent=2))


def cmd_purchased(args, base_url, token):
    qs = urllib.parse.urlencode({"status": "purchased_by_me", "page": str(args.page)})
    data = _api_get(base_url, f"{ASSETS_PATH}/user?{qs}", token)
    print(json.dumps(data, indent=2))


def cmd_liked(args, base_url, token):
    qs = urllib.parse.urlencode({"status": "liked_by_me", "page": str(args.page)})
    data = _api_get(base_url, f"{ASSETS_PATH}/user?{qs}", token)
    print(json.dumps(data, indent=2))


def cmd_my_assets(args, base_url, token):
    qs = urllib.parse.urlencode({"page": str(args.page)})
    data = _api_get(base_url, f"{ASSETS_PATH}/user?{qs}", token)
    print(json.dumps(data, indent=2))


# ── Auth loading ─────────────────────────────────────────────────────────────

def load_auth(args):
    if args.token and args.base_url:
        return args.base_url, args.token

    if args.auth_file:
        try:
            with open(args.auth_file, "r") as f:
                data = json.load(f)
        except (OSError, json.JSONDecodeError) as e:
            print(f"Error: Cannot read auth file: {e}", file=sys.stderr)
            sys.exit(1)

        if not data.get("success"):
            print(f"Error: Auth failed — {data.get('error', 'unknown')}", file=sys.stderr)
            sys.exit(1)

        return data["base_url"], data["session_token"]

    print("Error: Provide --auth-file or --token/--base-url.", file=sys.stderr)
    sys.exit(1)


# ── CLI ──────────────────────────────────────────────────────────────────────

def main():
    parser = argparse.ArgumentParser(
        description="Highrise Studio Asset Catalog CLI (read-only browsing)",
    )

    auth_group = parser.add_argument_group("auth")
    auth_group.add_argument("--auth-file", help="Path to catalog_result.json from .catalog trigger")
    auth_group.add_argument("--token", help="Session token (e.g. hr_s_xxx=yyy)")
    auth_group.add_argument("--base-url", help="API base URL")

    subparsers = parser.add_subparsers(dest="command", required=True)

    p_list = subparsers.add_parser("list", help="List published assets")
    p_list.add_argument("--category", choices=VALID_CATEGORIES, help="Filter by category")
    p_list.add_argument("--page", type=int, default=0, help="Page number (default: 0)")
    p_list.add_argument("--search", help="Search query (min 3 characters)")
    p_list.add_argument("--bundle", type=bool, default=None, help="Filter bundles (true/false)")
    p_list.add_argument("--free", action="store_true", help="Only show free assets")
    p_list.add_argument("--has-scripts", action="store_true", help="Only show assets with scripts")

    p_get = subparsers.add_parser("get", help="Get asset details")
    p_get.add_argument("id", help="Asset ID")

    p_purch = subparsers.add_parser("purchased", help="List purchased assets")
    p_purch.add_argument("--page", type=int, default=0, help="Page number (default: 0)")

    p_liked = subparsers.add_parser("liked", help="List liked assets")
    p_liked.add_argument("--page", type=int, default=0, help="Page number (default: 0)")

    p_my = subparsers.add_parser("my-assets", help="List your own assets")
    p_my.add_argument("--page", type=int, default=0, help="Page number (default: 0)")

    args = parser.parse_args()
    base_url, token = load_auth(args)

    commands = {
        "list": cmd_list,
        "get": cmd_get,
        "purchased": cmd_purchased,
        "liked": cmd_liked,
        "my-assets": cmd_my_assets,
    }

    commands[args.command](args, base_url, token)


if __name__ == "__main__":
    main()
