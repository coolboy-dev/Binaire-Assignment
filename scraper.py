import csv
import html
import re
import sys
import time
import urllib.request

BASE = "https://www.lexaloffle.com"
LISTING_URL = BASE + "/bbs/?sub=2&mode=carts&cat=7&orderby=ts&page={page}"
CART_URL = BASE + "/bbs/?tid={tid}"

HEADERS = {
    "User-Agent": (
        "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 "
        "(KHTML, like Gecko) Chrome/120.0 Safari/537.36"
    )
}

ROW_RE = re.compile(
    r"\['(?P<pid>\d+)',\s*(?P<tid>\d+),\s*`(?P<title>.*?)`,\s*"
    r"\"(?P<thumb>[^\"]*)\",\s*[\d.]+,\s*[\d.]+,\s*\"[^\"]*\",\s*"
    r"(?P<author_id>\d+),\s*\"(?P<author>[^\"]*)\",\s*\"[^\"]*\",\s*"
    r"\d+,\s*\"[^\"]*\",\s*(?P<likes>\d+),\s*(?P<comments>\d+),"
)

DESC_START_RE = re.compile(r"</textarea>\s*</div>\s*</div>\s*<br>")
DESC_END_RE = re.compile(
    r'<div style="display:table; margin-bottom:8px; margin-top: 8px">'
    r"|<div class=form_button"
)
LICENSE_RE = re.compile(
    r'License:</span>\s*<a[^>]*href="([^"]+)"[^>]*>([^<]+)</a>'
)
CART_FILE_RE = re.compile(
    r'href="(/bbs/cposts/[a-z0-9]{2}/([^"]+)\.p8\.png)">Cart File</a>'
)
OG_IMAGE_RE = re.compile(r'property="og:image" content="([^"]+)"')
COMMENT_RE = re.compile(
    r'<div id=p(?P<pid>\d+) style="display:flex;.*?'
    r'<a href="/bbs/\?uid=\d+"><b style="color:#fff;font-size:12pt">'
    r"(?P<author>[^<]+)</b></a>.*?"
    r'<div style="min-height:44px;">(?P<body>.*?)</div>',
    re.S,
)


def fetch(url, retries=3, delay=1.5):
    req = urllib.request.Request(url, headers=HEADERS)
    for attempt in range(retries):
        try:
            with urllib.request.urlopen(req, timeout=20) as resp:
                return resp.read().decode("utf-8", errors="replace")
        except Exception as exc:
            if attempt == retries - 1:
                raise
            print(f"  retry ({exc}) ...", file=sys.stderr)
            time.sleep(delay)


def clean_html_fragment(frag):
    frag = re.sub(r"<iframe[^>]*snippet\.php[^>]*>.*?</iframe>", "", frag, flags=re.S)
    frag = re.sub(r"Copy and paste the snippet below into your HTML\.", "", frag)
    frag = re.sub(r"<textarea[^>]*>.*?</textarea>", " ", frag, flags=re.S)
    frag = re.sub(r"<script[^>]*>.*?</script>", " ", frag, flags=re.S)
    frag = re.sub(r"<style[^>]*>.*?</style>", " ", frag, flags=re.S)
    frag = re.sub(r"<(br|p|div|li|h[1-6])[^>]*>", " ", frag, flags=re.I)
    text = re.sub(r"<[^>]+>", " ", frag)
    text = html.unescape(text)
    return re.sub(r"\s+", " ", text).strip()


def list_cart_stubs(target_count):
    """Fetch listing pages until we have >= target_count cart stubs."""
    stubs = []
    seen_tids = set()
    page = 1
    while len(stubs) < target_count:
        url = LISTING_URL.format(page=page)
        print(f"Fetching listing page {page} ...", file=sys.stderr)
        html_page = fetch(url)
        m = re.search(r"pdat=\[(.*?)\n\t\t\];", html_page, re.S)
        if not m:
            break
        rows = ROW_RE.finditer(m.group(1))
        found_this_page = 0
        for row in rows:
            tid = row.group("tid")
            if tid in seen_tids:
                continue
            seen_tids.add(tid)
            stubs.append(
                {
                    "pid": row.group("pid"),
                    "tid": tid,
                    "title": html.unescape(row.group("title")),
                    "author": html.unescape(row.group("author")),
                    "likes": row.group("likes"),
                    "comments": row.group("comments"),
                }
            )
            found_this_page += 1
        if found_this_page == 0:
            break
        page += 1
        time.sleep(0.5)
    return stubs[:target_count]


def scrape_cart_detail(stub):
    url = CART_URL.format(tid=stub["tid"])
    page = fetch(url)

    og_image = OG_IMAGE_RE.search(page)
    artwork = og_image.group(1) if og_image else ""

    cart_file = CART_FILE_RE.search(page)
    game_code = cart_file.group(2) if cart_file else ""

    lic = LICENSE_RE.search(page)
    if lic:
        license_str = f"{lic.group(2).strip()} ({lic.group(1).strip()})"
    elif "No License</a>" in page:
        license_str = "No License"
    else:
        license_str = ""

    description = ""
    start_m = DESC_START_RE.search(page)
    if start_m:
        start = start_m.end()
        end_m = DESC_END_RE.search(page, start)
        end = end_m.start() if end_m else start + 4000
        description = clean_html_fragment(page[start:end])

    comments = []
    idx = page.find("id=comments")
    if idx != -1:
        for cm in COMMENT_RE.finditer(page[idx:]):
            text = clean_html_fragment(cm.group("body"))
            if text:
                comments.append(f"{cm.group('author')}: {text}")
            if len(comments) >= 5:
                break

    return {
        "name": stub["title"],
        "author": stub["author"],
        "artwork": artwork,
        "game_code": game_code,
        "license": license_str,
        "like_count": stub["likes"],
        "description": description,
        "top_5_comments": " || ".join(comments),
        "game_url": url,
    }


def main(count=100, out_path="pico8_games.csv"):
    stubs = list_cart_stubs(count)
    print(f"Collected {len(stubs)} cart stubs, scraping details ...", file=sys.stderr)

    rows = []
    for i, stub in enumerate(stubs, 1):
        print(f"[{i}/{len(stubs)}] {stub['title']} (tid={stub['tid']})", file=sys.stderr)
        try:
            rows.append(scrape_cart_detail(stub))
        except Exception as exc:
            print(f"  FAILED: {exc}", file=sys.stderr)
        time.sleep(0.4)

    fieldnames = [
        "name",
        "author",
        "artwork",
        "game_code",
        "license",
        "like_count",
        "description",
        "top_5_comments",
        "game_url",
    ]
    with open(out_path, "w", newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(rows)

    print(f"Wrote {len(rows)} rows to {out_path}", file=sys.stderr)


if __name__ == "__main__":
    n = int(sys.argv[1]) if len(sys.argv) > 1 else 100
    out = sys.argv[2] if len(sys.argv) > 2 else "pico8_games.csv"
    main(n, out)
