"""Checks store/play/LISTING.md against Google Play's text limits."""
import re
import sys

text = open("store/play/LISTING.md", encoding="utf-8").read()


def section(title, nxt):
    m = re.search(rf"## {re.escape(title)}.*?\n(.*?)\n## {re.escape(nxt)}", text, re.S)
    return m.group(1)


ok = True
name = section("App name (max 30)", "Short description").strip()
checks = [("App name", name, 30)]
short = section("Short description (max 80)", "Full description")
for lang, body in re.findall(r"### (\S+)\n(.*?)(?=\n### |\Z)", short, re.S):
    checks.append((f"Short description ({lang})", body.strip(), 80))
full = section("Full description (max 4000)", "Store settings")
for lang, body in re.findall(r"### (\S+)\n(.*?)(?=\n### |\Z)", full, re.S):
    checks.append((f"Full description ({lang})", body.strip(), 4000))
for label, value, limit in checks:
    n = len(value)
    flag = "OK " if n <= limit else "TOO LONG"
    ok &= n <= limit
    print(f"{flag} {label}: {n}/{limit}")
sys.exit(0 if ok else 1)
