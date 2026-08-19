# Project notes for agents

Deliberate decisions in this repo - do NOT silently revert them:

- This fork dropped nix-darwin/home-manager entirely (2026-08). Everything is Homebrew plus direct symlinks created by `bootstrap.sh`. Do not reintroduce Nix, flakes, or home-manager; upstream (`kunchenguid/dotfiles`) still uses them, so upstream merges will conflict here - resolve in favor of the brew+symlink model.
- No SSH remote access. sshd stays off deliberately; do not enable it. The `tailscale-app` cask stays - it is used for other things, not for SSH, so it is not orphaned config. Note that `herdr --remote` is SSH transport only, so it does not work while sshd is off.
- `home/.claude/settings.json` is tracked *and* symlinked to `~/.claude/settings.json`, so tools write to it through the symlink. `herdr integration install claude` adds a `hooks.SessionStart` block pointing at `~/.claude/hooks/herdr-agent-state.sh`. That block and the script are herdr-generated and herdr-versioned - `bootstrap.sh` step 8 installs them. Do not commit the block: a pinned copy goes stale on the next herdr upgrade and hardcodes one user's absolute path. Seeing it as an uncommitted diff is expected.
- Never commit `.no-mistakes/` validation evidence to this public repo. `.no-mistakes/` is gitignored; if a validation pipeline stages evidence into a branch, drop it before merging.

## Maintaining this file

Keep this file for knowledge useful to almost every future agent session in this project.
Do not repeat what the codebase already shows; point to the authoritative file or command instead.
Prefer rewriting or pruning existing entries over appending new ones.
When updating this file, preserve this bar for all agents and keep entries concise.
