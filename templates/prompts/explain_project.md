# Explain this project

Write an onboarding overview of the current repository for a developer seeing it for the first time.

## Steps

1. Read the README, contributing guide, and any `AGENTS.md` or `CLAUDE.md`. Then read the manifests (`package.json`, `Cargo.toml`, `pyproject.toml`, `go.mod`, `Makefile`, etc.) for dependencies and scripts.
2. Map the layout: list the top-level directories and the first level beneath the important ones. Identify entry points (main files, CLI definitions, server bootstraps, routes) and open them.
3. Find the build, run, and test commands from scripts, CI config (`.github/workflows`), and docs. Run the quick ones such as `--help` or a dry build only if they are safe; otherwise report them as untested.
4. Skim `git log --oneline -20` to see what is actively changing.
5. Verify claims against the code. Mark anything inferred from names alone as an assumption.

## Output

- **Purpose**: what the project does and for whom, in two or three sentences.
- **Architecture**: the main components, how they interact, and where data and control flow, with paths. A small ASCII diagram is fine.
- **Tech stack**: languages, frameworks, key dependencies, external services.
- **Build, run, test**: exact commands, required tools and environment variables, and whether you ran them.
- **Where to start**: for common changes (add an endpoint, change a config, fix a bug, add a test) name the files to open first.
- **Conventions and risks**: code style, branching, generated files, fragile or undocumented areas.

## Notes

{{_cursor_}}
