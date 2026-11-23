#!/usr/bin/env python3
"""Build music/catalog.json for BreatheCare from a folder of MP3s.

Folder layout (one sub-folder per category id, e.g. piano, flute, focus):

    my_music/
      piano/
        morning-stillness.mp3
        morning-stillness.jpg        (optional cover, same name; .jpg/.png/.webp)
      flute/
        soft-bansuri.mp3

Usage:
    pip install mutagen            # optional, for automatic durations
    python3 tools/make_music_catalog.py my_music --artist "Your Name" > catalog.json

Then edit titles/descriptions in catalog.json and upload (see README).
"""
import argparse
import datetime
import json
import os
import re
import sys

CATEGORIES = {
    "relaxation", "meditation", "guided", "piano", "instrumental", "flute", "indian", "bowls",
    "stress", "focus", "ambient", "yoga", "mindfulness", "morning", "short",
}


def duration_of(path):
    try:
        from mutagen.mp3 import MP3  # type: ignore
        return int(round(MP3(path).info.length))
    except Exception:
        return 0


def slug(name):
    return re.sub(r"[^a-z0-9]+", "-", name.lower()).strip("-")


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("folder")
    ap.add_argument("--artist", default="")
    args = ap.parse_args()
    today = datetime.date.today().isoformat()
    tracks = []
    for category in sorted(os.listdir(args.folder)):
        cat_dir = os.path.join(args.folder, category)
        if not os.path.isdir(cat_dir):
            continue
        if category not in CATEGORIES:
            print(f"warning: unknown category folder '{category}'", file=sys.stderr)
        for f in sorted(os.listdir(cat_dir)):
            if not f.lower().endswith(".mp3"):
                continue
            base = os.path.splitext(f)[0]
            track_id = slug(base)
            cover = next(
                (f"music/covers/{track_id}{ext}" for ext in (".jpg", ".png", ".webp")
                 if os.path.exists(os.path.join(cat_dir, base + ext))),
                None,
            )
            t = {
                "id": track_id,
                "title": base.replace("-", " ").replace("_", " ").title(),
                "artist": args.artist,
                "category": category,
                "duration": duration_of(os.path.join(cat_dir, f)),
                "description": "",
                "audio": f"music/audio/{track_id}.mp3",
                "added": today,
                "featured": False,
            }
            if cover:
                t["cover"] = cover
            tracks.append(t)
    json.dump({"version": 1, "updated": today, "tracks": tracks}, sys.stdout, ensure_ascii=False, indent=2)
    print(file=sys.stdout)


if __name__ == "__main__":
    main()
