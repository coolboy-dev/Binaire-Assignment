#!/usr/bin/env python3
"""
Builds a SQLite + FTS5 RAG database from games_with_code.csv and the
decoded Lua source files in carts_lua/.

Two retrieval granularities:
  - games / games_fts       : one row per game (metadata + full source),
                               for "show me games like X" queries.
  - code_chunks / chunks_fts: game source split into ~60-line overlapping
                               windows, for "how do I implement X" queries
                               that should surface a focused snippet rather
                               than a whole 40KB cart.

FTS5 gives lexical (BM25) retrieval -- no embedding model or third-party
package is required, which matters here since this environment has no pip
access. BM25 over PICO-8 API calls, comments, and descriptions works well in
practice because game code and prompts share vocabulary (spr, btn, _update,
"platformer", "collision", etc).

Usage: python3 build_rag_db.py [games_with_code.csv] [pico8_rag.db]
"""

import csv
import sqlite3
import sys

CHUNK_LINES = 60
CHUNK_OVERLAP = 12


def chunk_code(code, chunk_lines=CHUNK_LINES, overlap=CHUNK_OVERLAP):
    lines = code.splitlines()
    if not lines:
        return []
    chunks = []
    start = 0
    step = max(1, chunk_lines - overlap)
    while start < len(lines):
        end = min(start + chunk_lines, len(lines))
        text = "\n".join(lines[start:end]).strip()
        if text:
            chunks.append((start + 1, text))
        if end == len(lines):
            break
        start += step
    return chunks


def build(csv_path, db_path):
    with open(csv_path, newline="", encoding="utf-8") as f:
        rows = list(csv.DictReader(f))

    con = sqlite3.connect(db_path)
    cur = con.cursor()
    cur.executescript(
        """
        PRAGMA journal_mode=WAL;

        DROP TABLE IF EXISTS games;
        CREATE TABLE games (
            id            INTEGER PRIMARY KEY,
            name          TEXT,
            author        TEXT,
            artwork       TEXT,
            game_code     TEXT,
            license       TEXT,
            like_count    INTEGER,
            description   TEXT,
            top_5_comments TEXT,
            game_url      TEXT,
            lua_code      TEXT,
            lua_chars     INTEGER,
            lua_lines     INTEGER
        );

        DROP TABLE IF EXISTS games_fts;
        CREATE VIRTUAL TABLE games_fts USING fts5(
            name, author, description, top_5_comments, lua_code,
            content='games', content_rowid='id',
            tokenize='porter unicode61'
        );

        DROP TABLE IF EXISTS code_chunks;
        CREATE TABLE code_chunks (
            id          INTEGER PRIMARY KEY,
            game_id     INTEGER NOT NULL REFERENCES games(id),
            start_line  INTEGER,
            chunk_text  TEXT
        );

        DROP TABLE IF EXISTS chunks_fts;
        CREATE VIRTUAL TABLE chunks_fts USING fts5(
            chunk_text,
            content='code_chunks', content_rowid='id',
            tokenize='porter unicode61'
        );
        """
    )

    n_chunks = 0
    for row in rows:
        if row.get("decode_status") != "ok":
            lua_code = ""
        else:
            try:
                with open(row["lua_path"], encoding="utf-8") as lf:
                    lua_code = lf.read()
            except (FileNotFoundError, KeyError):
                lua_code = ""

        cur.execute(
            """INSERT INTO games
               (name, author, artwork, game_code, license, like_count,
                description, top_5_comments, game_url, lua_code, lua_chars, lua_lines)
               VALUES (?,?,?,?,?,?,?,?,?,?,?,?)""",
            (
                row["name"], row["author"], row["artwork"], row["game_code"],
                row["license"], int(row["like_count"] or 0), row["description"],
                row["top_5_comments"], row["game_url"], lua_code,
                len(lua_code), lua_code.count("\n") + (1 if lua_code else 0),
            ),
        )
        game_id = cur.lastrowid

        for start_line, chunk_text in chunk_code(lua_code):
            cur.execute(
                "INSERT INTO code_chunks (game_id, start_line, chunk_text) VALUES (?,?,?)",
                (game_id, start_line, chunk_text),
            )
            n_chunks += 1

    cur.execute("INSERT INTO games_fts(rowid, name, author, description, top_5_comments, lua_code) "
                "SELECT id, name, author, description, top_5_comments, lua_code FROM games")
    cur.execute("INSERT INTO chunks_fts(rowid, chunk_text) "
                "SELECT id, chunk_text FROM code_chunks")

    con.commit()
    con.close()
    print(f"Built {db_path}: {len(rows)} games, {n_chunks} code chunks.", file=sys.stderr)


if __name__ == "__main__":
    args = sys.argv[1:]
    csv_path = args[0] if len(args) > 0 else "games_with_code.csv"
    db_path = args[1] if len(args) > 1 else "pico8_rag.db"
    build(csv_path, db_path)
