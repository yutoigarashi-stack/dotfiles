"""Reject external installer calls during a complete install.sh dry-run."""

import os
import subprocess
import tempfile
from pathlib import Path

with tempfile.TemporaryDirectory(prefix="dotfiles-dry-run-") as directory:
    root = Path(directory)
    log = root / "calls"
    for command in ("brew", "claude", "codex", "herdr"):
        stub = root / command
        stub.write_text(
            '#!/bin/bash\n'
            'printf "%s\\n" "$0 $*" >> "$DRY_RUN_CALL_LOG"\n'
            # Fish is deliberately absent so brew install must be simulated.
            'if [[ "${0##*/}" == brew && "$*" == "list fish" ]]; then\n'
            '    exit 1\n'
            'fi\n'
            'echo "Unexpected external command: $0 $*" >&2\n'
            'exit 99\n'
        )
        stub.chmod(0o755)
    result = subprocess.run(
        ["bash", "install.sh", "--dry-run"],
        env={
            **os.environ,
            "PATH": f"{root}{os.pathsep}{os.environ['PATH']}",
            "DRY_RUN_CALL_LOG": str(log),
        },
        stdin=subprocess.DEVNULL,
        capture_output=True,
        text=True,
        check=True,
    )
    calls = log.read_text().splitlines()
    if calls != [f"{root}/brew list fish"]:
        raise SystemExit(f"Unexpected external calls: {calls}")
    for expected in ("brew install fish", "claude plugin", "codex plugin", "ln -s"):
        if not any(
            line.startswith("[dry-run]") and expected in line
            for line in result.stdout.splitlines()
        ):
            raise SystemExit(f"Missing dry-run operation: {expected}")
    print(result.stdout, end="")
    print("OK: dry-run did not run installers or request input")
