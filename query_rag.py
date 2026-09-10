#!/usr/bin/env python3
"""
Retrieval interface over pico8_rag.db for grounding PICO-8 Lua code
generation.

Two retrieval modes:
  games   -- whole matching carts (metadata + full source). Good when the
             user's ask resembles an existing game ("a flappy bird clone").
  chunks  -- focused ~60-line code snippets across all carts. Good for
             "how do I do X" style asks ("player-vs-wall collision").

CLI:
    python3 query_rag.py "gravity based flappy bird clone" --mode games -k 3
    python3 query_rag.py "aabb collision detection" --mode chunks -k 5
    python3 query_rag.py "space shooter with enemies" --context   # prints an
        assembled prompt block ready to paste in front of a code-gen request

Library:
    from query_rag import search_games, search_chunks, build_context
"""

import argparse
import re
import sqlite3
import sys

DB_PATH_DEFAULT = "pico8_rag.db"


def _fts_query(text):
    """Turn free text into an FTS5 MATCH query: OR of quoted terms, so any
    overlapping keyword contributes to the BM25 score instead of requiring
    every term to match."""
    terms = re.findall(r"[A-Za-z0-9_]+", text)
    if not terms:
        return '""'
    return " OR ".join(f'"{t}"' for t in terms)


def search_games(query, k=5, db_path=DB_PATH_DEFAULT):
    con = sqlite3.connect(db_path)
    con.row_factory = sqlite3.Row
    rows = con.execute(
        """
        SELECT g.id, g.name, g.author, g.description, g.like_count,
               g.license, g.game_url, g.lua_code,
               bm25(games_fts) AS score
        FROM games_fts
        JOIN games g ON g.id = games_fts.rowid
        WHERE games_fts MATCH ?
        ORDER BY score
        LIMIT ?
        """,
        (_fts_query(query), k),
    ).fetchall()
    con.close()
    return [dict(r) for r in rows]


def search_chunks(query, k=8, db_path=DB_PATH_DEFAULT):
    con = sqlite3.connect(db_path)
    con.row_factory = sqlite3.Row
    rows = con.execute(
        """
        SELECT c.id, c.game_id, c.start_line, c.chunk_text,
               g.name, g.author, g.license, g.game_url,
               bm25(chunks_fts) AS score
        FROM chunks_fts
        JOIN code_chunks c ON c.id = chunks_fts.rowid
        JOIN games g ON g.id = c.game_id
        WHERE chunks_fts MATCH ?
        ORDER BY score
        LIMIT ?
        """,
        (_fts_query(query), k),
    ).fetchall()
    con.close()
    return [dict(r) for r in rows]


def build_context(query, k_games=2, k_chunks=6, db_path=DB_PATH_DEFAULT, max_chars=12000):
    """Assemble a retrieval-augmented prompt block: a few relevant code
    chunks plus a couple of full reference carts, capped to max_chars so it
    fits comfortably in a code-gen prompt."""
    chunks = search_chunks(query, k=k_chunks, db_path=db_path)
    games = search_games(query, k=k_games, db_path=db_path)

    parts = [
        "# PICO-8 reference material retrieved for this request",
        f"# query: {query!r}",
        "",
    ]
    budget = max_chars

    if chunks:
        parts.append("## Relevant code snippets (from real published PICO-8 carts)\n")
        for c in chunks:
            block = (
                f"--- snippet from \"{c['name']}\" by {c['author']} "
                f"(line {c['start_line']}, license: {c['license'] or 'unspecified'}) ---\n"
                f"```lua\n{c['chunk_text']}\n```\n"
            )
            if len(block) > budget:
                break
            parts.append(block)
            budget -= len(block)

    if games and budget > 500:
        parts.append("## Similar whole games\n")
        for g in games:
            desc = (g["description"] or "").strip()
            header = (
                f"- \"{g['name']}\" by {g['author']} ({g['like_count']} likes) "
                f"-- {desc[:200]}\n  source: {g['game_url']}\n"
            )
            if len(header) > budget:
                break
            parts.append(header)
            budget -= len(header)

    parts.append(
        "\n# Use the patterns above (API usage, structure, idioms) as grounding.\n"
        "# Do not copy verbatim if a license restricts reuse -- check the license field.\n"
    )
    return "\n".join(parts)


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("query")
    ap.add_argument("--mode", choices=["games", "chunks"], default="chunks")
    ap.add_argument("-k", type=int, default=5)
    ap.add_argument("--db", default=DB_PATH_DEFAULT)
    ap.add_argument("--context", action="store_true", help="print an assembled RAG context block instead")
    args = ap.parse_args()

    if args.context:
        print(build_context(args.query, db_path=args.db))
        return

    if args.mode == "games":
        for g in search_games(args.query, k=args.k, db_path=args.db):
            print(f"[{g['score']:.2f}] {g['name']} by {g['author']} ({g['like_count']} likes)")
            print(f"    {g['game_url']}  license={g['license'] or 'unspecified'}")
            if g["description"]:
                print(f"    {g['description'][:160]}")
            print()
    else:
        for c in search_chunks(args.query, k=args.k, db_path=args.db):
            print(f"[{c['score']:.2f}] {c['name']} by {c['author']} (line {c['start_line']})")
            print("    " + "\n    ".join(c["chunk_text"].splitlines()[:8]))
            print("    ...\n")


if __name__ == "__main__":
    main()
