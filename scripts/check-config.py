"""Validate tracked JSON/TOML files and the current Neovim plugin lockfile."""

import json
import re
import subprocess
import tomllib
from pathlib import Path

for name in subprocess.check_output(
    ["git", "ls-files", "-z", "*.json", "*.toml"], text=True
).split("\0"):
    if not name:
        continue
    path = Path(name)
    with path.open("rb") as stream:
        if path.suffix == ".toml":
            tomllib.load(stream)
        else:
            json.load(stream)
    print(f"OK: {name}")

# The current init.lua declares plugins with literal owner/repository strings.
plugins = {
    name.rsplit("/", 1)[1]
    for name in re.findall(r'"([\w.-]+/[\w.-]+)"', Path("nvim/init.lua").read_text())
} | {"lazy.nvim"}
lock = json.loads(Path("nvim/lazy-lock.json").read_text())
if set(lock) != plugins:
    raise SystemExit(
        f"lockfile mismatch: missing={plugins - set(lock)}, extra={set(lock) - plugins}"
    )
for name, entry in lock.items():
    if not entry.get("branch") or not re.fullmatch(r"[0-9a-f]{40}", entry["commit"]):
        raise SystemExit(f"Invalid lockfile entry: {name}")
print("OK: Neovim plugin lockfile")
