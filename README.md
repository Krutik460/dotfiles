# laptop-setup

My personal Mac setup, managed with Homebrew and plain symlinks.
One repo, one script, and a fresh Mac ends up configured the same way every time.

This setup started from [kunchenguid/dotfiles](https://github.com/kunchenguid/dotfiles), which manages everything with nix-darwin and home-manager.
This repo dropped Nix entirely in favor of Homebrew plus direct symlinks, and its history starts fresh from that point.

## Contributing / Using This Repo

These are personal dotfiles, shared publicly so people can read them, learn from them, and fork them freely.
Feature requests and pull requests are not accepted here.
If you find a bug, please open a GitHub Issue.

## What you get

Running `bootstrap.sh` sets up:

- System settings (dark mode, key repeat, dock, Finder, trackpad)
- Homebrew apps and CLI tools (WezTerm, Tailscale, herdr, starship, zsh plugins, and the glow/delta/bat renderers herdr's file-viewer plugin uses)
- Claude Code via the native installer (self-updates with `claude update`)
- Shell (zsh with autosuggestions and syntax highlighting, aliases, starship prompt)
- Terminal (WezTerm config with the rose-pine moon theme, dimmed unfocused windows, Hack Nerd Font)
- Editor config (Neovim config with the rose-pine moon theme; Neovim itself isn't installed - `brew install neovim` if you want it)
- Agent configs (Claude, Codex, opencode all share one AGENTS.md; Claude also gets the repo-authored skills under `home/.claude/skills/`)
- Optional Pi theme and local extensions, generic UI settings and model overrides, plus two deliberately pinned third-party Pi packages
- herdr plugins and its Claude integration

## Prerequisites

- Apple Silicon Mac. Intel works too, but the scripts and shell config assume Homebrew's `/opt/homebrew` prefix; on Intel, adjust the paths to `/usr/local`.

## Fresh-machine setup

On a brand new Mac, from a bare clone of this repo:

```sh
git clone https://github.com/Krutik460/laptop-setup.git
cd laptop-setup
./bootstrap.sh
```

`bootstrap.sh` does eight things, in order:

1. Installs Homebrew, if it isn't already installed.
2. Symlinks this repo to `~/.dotfiles`.
   Every config symlink resolves through `~/.dotfiles`, so if the repo ever moves, only that one link needs updating.
3. Installs the Homebrew packages (formulas and casks).
4. Installs Claude Code with its native installer, which self-updates via `claude update`.
5. Creates the dotfile symlinks (shell, starship, WezTerm, Neovim, herdr, agent configs, Pi files).
6. Applies the macOS defaults with `defaults write`.
7. Installs herdr plugins (currently [herdr-file-viewer](https://github.com/smarzban/herdr-file-viewer)).
   Plugin state embeds machine-specific paths, so it's gitignored and installed imperatively here.
8. Installs herdr's Claude integration (`herdr integration install claude`), which reports agent state back to the herdr agent panel.
   It writes a hook script and a `hooks` block into `~/.claude/settings.json`; both are herdr-generated and overwritten on herdr upgrades, so they're installed here rather than committed.

The script is idempotent - rerun it any time after adding a package or symlink.

## Daily use

Edit the files under `home/` in place.
Everything is symlinked, so changes apply immediately - there is no build or switch step.
If you add a new package or a new config file, add it to `bootstrap.sh` (the package list or the symlink block) and rerun the script.

## Make it yours

This repo is mine.
If you clone it, review these before you run `bootstrap.sh`:

- **`home/AGENTS.md` is my personal agent policy**, installed for Claude, Codex, and opencode.
  If you clone this repo, you'd silently inherit my agent instructions - edit or delete `home/AGENTS.md` if you don't want that.
- **The `cc` and `co` shell aliases** in `home/.zshrc` are high-agency shortcuts: `claude --dangerously-skip-permissions` and `codex --full-auto`.
  They're convenient for me, but know what they do before you use them.
- **Git identity:** this config deliberately does not set your git name or email.
  Git will stop your first commit and tell you to set them (`git config --global user.name "Your Name"` and `git config --global user.email you@example.com`).
- **Homebrew packages:** `bootstrap.sh` only installs; it never uninstalls anything, so whatever you already have on your machine is left alone.
- **About `herdr`:** it's a real public Homebrew formula (`brew info herdr` finds it in homebrew-core, no tap needed), so it will install fine.
  If you don't use it, remove it from the `brew install` line - the plugin and integration steps skip themselves when herdr isn't installed.

## Repo tour

- `bootstrap.sh` - the entire setup: Homebrew, packages, symlinks, macOS defaults, herdr plugins.
- `home/` - the actual config files that get symlinked into place; the sections below explain the shared symlink model and Pi's narrower selective setup.
- `tests/` - deterministic checks for the Pi Calm extension.

## How the symlinks work

The files under `home/` are the real files - editing them here is editing your live config.
`bootstrap.sh` points paths like `~/.config/nvim` straight at `home/.config/nvim` through the `~/.dotfiles` link, so the two never drift out of sync.
You only rerun `./bootstrap.sh` when you change something that isn't a symlinked file, like the package list or a system default.

## Optional Pi configuration

Pi is an opt-in CLI, not a dependency this repository vendors. Install it from its owner with the [official Pi instructions](https://pi.dev), for example:

```sh
npm install -g --ignore-scripts @earendil-works/pi-coding-agent
```

[Pi Launcher](https://github.com/kunchenguid/homebrew-tap) is also optional and installed from its owner, not declared by this config:

```sh
brew install --cask kunchenguid/tap/pi-launcher
```

`bootstrap.sh` links exactly two repository-authored Pi directories: `~/.pi/agent/themes` and `~/.pi/agent/extensions`. It also links `models.json` and `settings.json` as individual files. The local extension directory is for public, repository-authored extensions only - third-party package code never belongs there. Run `/reload` after editing a local extension or other Pi resources. The terminal-title extension shows a spinner while Pi is working, then a completion mark with the session name or current directory. The `rose-pine-moon` theme was authored clean-room from the public [Rosé Pine Moon palette](https://rosepinetheme.com/palette) and Pi's [public theme schema](https://raw.githubusercontent.com/earendil-works/pi/main/packages/coding-agent/src/modes/interactive/theme/theme-schema.json), not from a private or live theme file.

### Pi Calm

`home/.pi/agent/extensions/calm` is a standalone local Pi extension. The existing global extensions-directory link makes Pi auto-load it without another declaration. `/calm` toggles a conversation-only presentation mode and is off by default. Its choice is stored locally in `~/.pi/agent/calm` (or the directory selected by `PI_CODING_AGENT_DIR`), not in this repository. Adapted from Firstmate under the bundled MIT license, Calm imports no Firstmate modules and has no Firstmate runtime dependency.

When enabled, Calm hides collapsed thinking and the call/result shells for Pi's seven built-in tools (`read`, `bash`, `edit`, `write`, `grep`, `find`, and `ls`) without leaving blank transcript rows. During an active run it replaces Pi's working row with a two-line animated blue-water, yellow-boat widget. `/calm` restores Pi's stock rendering and preserves the existing Ctrl+O tool-expansion choice.

Calm never changes prompts, tool execution, model context, session data, or ordering. `/share` and `/export` use the complete stock transcript. Generic custom tools, images, and unsupported Pi transcript classes deliberately remain visible because Pi has no safe general-purpose transcript filter. If a future Pi release no longer exports the exact collapsed-thinking rendering seam, Calm logs one diagnostic and leaves only that adapter disabled; all other behavior remains available.

Pi's package system declares two third-party sources in the linked global `settings.json`:

- `npm:@ryan_nookpi/pi-extension-codex-fast-mode@0.2.6` - the exact public npm release from `ryan_nookpi`.
- `git:github.com/algal/pi-openai-server-compaction@c6d593087709e9481223dc6c6c2269b371b5e055` - the exact public `algal` commit for experimental OpenAI server-side compaction.

The version and commit are immutable pins, so Pi does not move them during package updates. Deliberate updates require a new source and security audit, followed by an explicit pin change in `home/.pi/agent/settings.json`. On Pi 0.82.0, global settings declarations install missing pinned packages automatically at startup. No one-time install command is required. Pi keeps the downloaded npm and git package trees in its own unmanaged `~/.pi/agent/npm` and `~/.pi/agent/git` runtime directories, outside this repo and Git tracking.

Both packages execute with your full user permissions and must be trusted like any other executable code. The compaction package is experimental, sends the relevant OpenAI compaction and continuity data to OpenAI, and upstream declares the stale peer range `>=0.80.9 <0.81.0`; this exact immutable ref was locally proven to load and perform remote compaction on Pi 0.82.0. Do not treat that proof as a guarantee for a different Pi version or a different package ref.

This repo deliberately does not manage `~/.pi/agent` itself, or Pi authentication, sessions, trust decisions, caches, npm/git package trees, or any other runtime state. The model overrides contain no credentials or endpoint settings, do not choose a default model, and only take effect after you authenticate Pi yourself. This remains an additive layer: it does not install Pi, a launcher, or package source code into this repository.

## Notes

The first time you launch `nvim`, it bootstraps [lazy.nvim](https://github.com/folke/lazy.nvim) by cloning plugins from GitHub.
That needs network access once; after that it's offline.
Neovim and WezTerm both use the rose-pine moon theme.
Neovim keeps italics off and uses a transparent background on macOS, Windows, and WSL so it matches the terminal setup.

## License

This repo is licensed under MIT No Attribution.
See `LICENSE`.
