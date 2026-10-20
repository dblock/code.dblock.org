"""Run full-archive spelling checks; Python requires pyspelling and Aspell."""

import json
import glob
import argparse
from pathlib import Path
import shutil
import subprocess
import tempfile
import time
import yaml

ROOT = Path(__file__).resolve().parents[2]
OUTPUT = Path(__file__).resolve().parent
BASELINE = "35bde6f7ec1b32a111e3c20471fcef3e8f87c657"


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--runs", type=int, default=3)
    args = parser.parse_args()
    if args.runs < 1:
        parser.error("--runs must be positive")
    paths = subprocess.check_output(["git", "ls-files", "-z"], cwd=ROOT).decode().split("\0")
    markdown = [
        path for path in paths
        if Path(path).suffix in {".md", ".markdown"}
    ]
    results = []
    with tempfile.TemporaryDirectory(prefix="blog-spelling-benchmark-") as directory:
        directory = Path(directory)
        for path in markdown + ["Gemfile", "Gemfile.lock", ".rubocop.yml", ".spellcheck.txt"]:
            target = directory / path
            target.parent.mkdir(parents=True, exist_ok=True)
            shutil.copyfile(ROOT / path, target)
        config = subprocess.check_output(["git", "show", f"{BASELINE}:.pyspelling.yml"], cwd=ROOT)
        config = yaml.safe_load(config)
        config["matrix"][0]["sources"] = [glob.escape(path) for path in markdown]
        (directory / ".pyspelling.yml").write_text(yaml.safe_dump(config))
        shutil.copyfile(ROOT / ".spellcheck.txt", directory / ".pyspelling.words")
        commands = {
            "pyspelling": ["pyspelling", "--config", ".pyspelling.yml", "--name", "Markdown", "--verbose"],
            "rubocop-spellcheck": [
                "bundle", "exec", "rubocop", "--only", "Spellcheck/Spelling",
                "--cache", "false", "--format", "json", "--", *markdown,
            ],
        }
        for round_number in range(1, args.runs + 1):
            for name, command in commands.items():
                start = time.perf_counter()
                process = subprocess.run(command, cwd=directory, capture_output=True, text=True)
                elapsed = time.perf_counter() - start
                (OUTPUT / f"{name}-{round_number}.log").write_text(process.stdout + process.stderr)
                if process.returncode not in (0, 1):
                    raise RuntimeError(process.stdout + process.stderr)
                if name == "pyspelling":
                    count = sum(line.startswith("> Processing: ") for line in process.stdout.splitlines())
                else:
                    count = json.loads(process.stdout)["summary"]["inspected_file_count"]
                if count != len(markdown):
                    raise RuntimeError(f"{name} checked {count} files; expected {len(markdown)}")
                result = {
                    "tool": name, "round": round_number, "seconds": elapsed,
                    "exit_code": process.returncode, "files": count,
                }
                results.append(result)
                print(json.dumps(result), flush=True)
    (OUTPUT / "tools-results.json").write_text(json.dumps(results, indent=2) + "\n")


if __name__ == "__main__":
    main()
