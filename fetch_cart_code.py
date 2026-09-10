#!/usr/bin/env python3
"""
Downloads the actual .p8.png cartridge for every game in pico8_games.csv and
decodes its embedded Lua source (via p8decode.py). Writes one .lua file per
game into carts_lua/, plus games_with_code.csv (the original metadata with
two extra columns: lua_path, lua_chars).

Usage: python3 fetch_cart_code.py [pico8_games.csv] [carts_lua/] [games_with_code.csv]
"""

import csv
import os
import re
import sys
import time
import urllib.request

from p8decode import decode_cart

BASE = "https://www.lexaloffle.com"
HEADERS = {
    "User-Agent": (
        "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 "
        "(KHTML, like Gecko) Chrome/120.0 Safari/537.36"
    )
}
CART_FILE_RE = re.compile(r'href="(/bbs/cposts/[a-z0-9]{2}/[^"]+\.p8\.png)">Cart File</a>')


def fetch(url, retries=3, delay=1.5):
    req = urllib.request.Request(url, headers=HEADERS)
    for attempt in range(retries):
        try:
            with urllib.request.urlopen(req, timeout=20) as resp:
                return resp.read()
        except Exception as exc:
            if attempt == retries - 1:
                raise
            time.sleep(delay)


def cart_png_url(game_code):
    prefix = game_code[:2].lower()
    return f"{BASE}/bbs/cposts/{prefix}/{game_code}.p8.png"


def resolve_via_thread(game_url):
    """Fallback: fetch the thread page and scrape the real Cart File href."""
    page = fetch(game_url).decode("utf-8", errors="replace")
    m = CART_FILE_RE.search(page)
    if not m:
        raise ValueError("no Cart File link found on thread page")
    return BASE + m.group(1)


def main(csv_path="pico8_games.csv", out_dir="carts_lua", out_csv="games_with_code.csv"):
    os.makedirs(out_dir, exist_ok=True)

    with open(csv_path, newline="", encoding="utf-8") as f:
        rows = list(csv.DictReader(f))

    fieldnames = list(rows[0].keys()) + ["lua_path", "lua_chars", "decode_status"]
    out_rows = []

    for i, row in enumerate(rows, 1):
        code_slug = row["game_code"]
        print(f"[{i}/{len(rows)}] {row['name']} ({code_slug})", file=sys.stderr)
        status = "ok"
        lua_path = ""
        lua_chars = 0
        try:
            url = cart_png_url(code_slug)
            try:
                png_bytes = fetch(url)
            except Exception:
                url = resolve_via_thread(row["game_url"])
                png_bytes = fetch(url)

            lua_code = decode_cart(png_bytes)
            safe_name = re.sub(r"[^A-Za-z0-9_.-]", "_", code_slug)
            lua_path = os.path.join(out_dir, f"{safe_name}.lua")
            with open(lua_path, "w", encoding="utf-8") as lf:
                lf.write(lua_code)
            lua_chars = len(lua_code)
        except Exception as exc:
            status = f"failed: {exc}"
            print(f"  FAILED: {exc}", file=sys.stderr)

        row["lua_path"] = lua_path
        row["lua_chars"] = lua_chars
        row["decode_status"] = status
        out_rows.append(row)
        time.sleep(0.3)

    with open(out_csv, "w", newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(out_rows)

    ok = sum(1 for r in out_rows if r["decode_status"] == "ok")
    print(f"Decoded {ok}/{len(out_rows)} carts. Wrote {out_csv} and {out_dir}/*.lua", file=sys.stderr)


if __name__ == "__main__":
    args = sys.argv[1:]
    main(*args)
