# herd

A tiny multi-agent coordinator for [herdr](https://herdr.dev). One Claude Code agent (the **head**) receives your tasks, delegates each one to a **worker** agent — Claude, Codex, Gemini, or any other herdr-supported kind — as a split pane beside itself (or, on request, its own tab), tracks their lifecycle, and collects their reports.

Three files, no daemon:

- **`herd-up`** — opens a `head` tab running Claude Code with the herd coordinator skill loaded as its system prompt.
- **`herd-spawn`** — spawns a worker as a pane split (default) or a new tab, hands it a task, and sets the report protocol. The head calls this; you can too.
- **`skills/herd/SKILL.md`** — the coordinator playbook: how to spawn, watch, unblock, and follow up with workers. Installed as a regular Claude Code skill, so any Claude Code session can also act as head via `/herd`.

## How it works

```
you ──task──▶ head (claude, tab "head")
                │  herd-spawn <name> <cwd> "<task>"
                ├──▶ worker pane "fix-auth"    (claude, split beside head)
                ├──▶ worker pane "review-auth" (codex, split beside fix-auth)
                │      … each writes its report to /tmp/herd/<name>.md
                └── watches:  herdr agent wait <name> --until done|idle|blocked
```

Each new worker splits off the previous worker's pane (not the head's), tiling in a spiral rather than shrinking a single strip; pass `-m tab` to open a worker in its own tab instead once panes get too cramped (past 3–4 concurrent workers).

Workers write a final report to `/tmp/herd/<name>.md`; the head treats the report file — not agent lifecycle state — as the real completion signal, summarizes results back to you, and shepherds blocked workers (routine prompts it answers itself via `send-keys`; anything risky it escalates to you).

## Requirements

- [herdr](https://herdr.dev) ≥ 0.7.5 (uses its `agent` automation CLI)
- [Claude Code](https://code.claude.com) (the head agent; also the default worker kind)
- `jq`
- Optional: any other agent CLIs you want as workers (`codex`, `gemini`, `cursor`, `droid`, `amp`, `grok`, …)

## Install

```sh
git clone https://github.com/vladzima/herd
cd herd
./install.sh
```

Scripts go to `~/.local/bin` (override with `HERD_BIN_DIR`), the skill to `~/.claude/skills/herd`.

## Use

Inside herdr, from the project you want to work on:

```sh
herd-up            # or: herd-up /path/to/project
```

Then either type tasks into the head tab, or send them from anywhere:

```sh
herdr agent prompt head "Fix the flaky auth test, then have a codex worker review the diff"
```

Spawn workers directly if you want to bypass the head:

```sh
herd-spawn fix-auth ~/proj "Fix the flaky auth test in tests/auth_test.py"
herd-spawn -k codex -a '-m gpt-5.6-terra --sandbox workspace-write' review-auth ~/proj "Review the auth diff"
herd-spawn -m tab docs-pass ~/proj "Update the docs for the new auth flow"
```

`-k` picks the agent kind (default `claude`), `-a` replaces the default agent args (for claude that default is `--permission-mode acceptEdits` — re-include a permission flag if you still want one), `-m` picks the spawn mode (`pane`, the default, or `tab`; also settable globally via `HERD_SPAWN_MODE`). Reports land in `/tmp/herd/<name>.md`.

You can also make any existing Claude Code session the head: just invoke the `/herd` skill.

## Uninstall

```sh
rm ~/.local/bin/herd-up ~/.local/bin/herd-spawn
rm -r ~/.claude/skills/herd
```

## License

[MIT](LICENSE)
