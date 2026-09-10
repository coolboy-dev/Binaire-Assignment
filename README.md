# PICO-8 BBS → RAG Pipeline

Scrapes the first 100 cartridges from the [Lexaloffle PICO-8 BBS](https://www.lexaloffle.com/bbs/?cat=7&carts_tab=1&#sub=2&mode=carts),
decodes their actual Lua source out of the `.p8.png` cartridge files, and
builds a local, dependency-free RAG (retrieval-augmented generation)
database you can query to ground PICO-8 code generation in real, working
examples.

Everything runs on the Python **standard library only** — no `pip install`
required (see [PIPELINE.md](PIPELINE.md) for why that constraint shaped the
design).

## Pipeline

```
scraper.py          → pico8_games.csv        (metadata: name, author, artwork,
                                                license, likes, description,
                                                top-5 comments, ...)
fetch_cart_code.py   → games_with_code.csv,    (downloads each .p8.png cart,
  (uses p8decode.py)   carts_lua/*.lua          decodes embedded Lua source)
build_rag_db.py      → pico8_rag.db           (SQLite + FTS5, two indexes:
                                                whole-game and code-chunk)
query_rag.py          (CLI / library)          — the retrieval interface
```

Run them in order to reproduce from scratch:

```bash
python3 scraper.py 100 pico8_games.csv
python3 fetch_cart_code.py pico8_games.csv carts_lua games_with_code.csv
python3 build_rag_db.py games_with_code.csv pico8_rag.db
```

Each step's output is already checked in here, so you can skip straight to
querying.

## Querying the RAG database

```bash
# Focused code snippets (best for "how do I implement X" asks)
python3 query_rag.py "player collision with walls" --mode chunks -k 5

# Whole matching games (best for "something like X" asks)
python3 query_rag.py "flappy bird clone with pipes and gravity" --mode games -k 3

# Assembled context block, ready to paste in front of a code-gen prompt
python3 query_rag.py "space shooter with enemy waves" --context > context.txt
```

Or as a library:

```python
from query_rag import search_games, search_chunks, build_context

context = build_context("simple pong game with two paddles", k_chunks=6, k_games=2)
# feed `context` + the user's request to an LLM to generate new PICO-8 Lua
```

## Files

| File | Purpose |
|---|---|
| `scraper.py` | Scrapes 100 cart listings + per-game metadata into `pico8_games.csv` |
| `p8decode.py` | Stdlib-only PNG decoder + PICO-8 cart decompressor (steganography → Lua) |
| `fetch_cart_code.py` | Downloads each cart's `.p8.png`, decodes it via `p8decode.py`, writes `carts_lua/*.lua` and `games_with_code.csv` |
| `build_rag_db.py` | Builds `pico8_rag.db` (SQLite/FTS5) from `games_with_code.csv` + `carts_lua/` |
| `query_rag.py` | CLI and library for querying the RAG database |
| `pico8_games.csv` | Raw scraped metadata (100 rows) |
| `games_with_code.csv` | Same metadata + `lua_path` / `lua_chars` / `decode_status` columns |
| `carts_lua/` | 100 decoded `.lua` source files, one per game |
| `pico8_rag.db` | The RAG database (100 games, 1,806 code chunks) |
| `PIPELINE.md` | Full technical write-up: how everything works and why |

## Requirements

Python 3.9+. Nothing else — no `pip install`. `sqlite3`'s FTS5 extension
must be compiled in (it is on all recent CPython builds).

## Data notes

- Every row has: name, author, artwork URL, cart code, license (or "No
  License"), like count, description, and up to 5 comments (author + text).
- Lua source decoded from 100/100 carts (verified by hand-reading several —
  comments, author credits, and PICO-8's special glyphs all decode intact).
- Licenses vary per cart (`CC4-BY-NC-SA` or `No License`) — `query_rag.py`
  surfaces the license alongside every retrieved snippet so you can respect
  it before reusing code verbatim.
- Retrieval is lexical (SQLite FTS5 + BM25), not embedding-based — see
  [PIPELINE.md](PIPELINE.md#why-fts5-instead-of-vector-embeddings) for why.
