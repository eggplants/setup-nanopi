# AGENTS.md

## What this repo is

The global [mise](https://mise.jdx.dev) config for a NanoPi R6S TV server (Debian 12 / FriendlyELEC image, aarch64). It is cloned as `~/.config/mise`, and `mise bootstrap` sets the machine up from it: apt sources and packages, system files and services, the mirakc / EPGStation / edcb-bridge Compose project, KonomiTV, and a few imperative steps. Family of [eggplants/setup-ubuntu.sh](https://github.com/eggplants/setup-ubuntu.sh); keep the same conventions.

## Apply the config

```bash
mise bootstrap --dry-run   # preview
mise bootstrap             # apply
```

## Architecture

| File | Purpose |
|------|---------|
| `config.toml` | `[tools]`, `[bootstrap.packages]` (apt), apt sources (Debian mirror, Docker, Tailscale, Grafana), system files, services, `[bootstrap.compose.tv]`, `[bootstrap.repos]` (zsh plugins, nano syntax), `[dotfiles]`, login shell (zsh), `bootstrap` task |
| `dotfiles/` | `[dotfiles]` sources (zsh, nano), taken from setup-ubuntu.sh minus the desktop-only parts |
| `compose/` | Compose project `tv`: mirakc, MariaDB, EPGStation, edcb-bridge. `scanned/` (ISDBScanner output) and EPGStation `data/` `thumbnail/` `logs/` are generated and gitignored |
| `scripts/install-debs.sh` | `post-packages` hook: kernel headers, px4_drv, recisdb, ISDBScanner, rkmppenc deps (`.deb` from GitHub releases), first channel scan |
| `tasks/setup/` | File tasks run by the `bootstrap` task: `system` (remove `pi`, hostname, timezone, locale, Tailscale), `docker`, `konomitv` |
| `tasks/hdd/init` | Formats and mounts the external storage at `/mnt/hdd1` (destructive; run by `bootstrap.sh` only when not mounted) |
| `tasks/tv/playlist` | Exports mirakc channels to `channels.m3u8` |
| `files/apt/` | Vendor apt signing keys |
| `files/ssh/authorized_keys` | SSH public key (`gpg --export-ssh-key`) |
| `bootstrap.sh` | Installs git/curl and mise, clones this repo, mounts the HDD, runs `mise bootstrap --update` |

### Key design decisions

- **Declarative first, tasks for the rest** — use `[bootstrap.*]` / `[dotfiles]` when mise can check the state. Hooks and the `bootstrap` task run on every `mise bootstrap`, so they must be idempotent (guard every step).
- **`.deb` from GitHub releases** — `apt:` entries cannot install a `.deb` by URL, so `install-debs.sh` installs them with the version pinned in the script; bump the version and URL together to upgrade.
- **Run order matters** — the `post-packages` hook runs before files/services/compose, so the tuner driver and `compose/scanned/mirakc/config.yml` exist before `[bootstrap.compose.tv]` starts mirakc.
- **Compose runs with `sudo = true`** — the user is added to the `docker` group only by `setup:docker` at the end, and the group takes effect after re-login.
- **KonomiTV** — installed by its interactive installer with answers piped in. It needs a reboot after the Mali driver is installed: the hook leaves `/run/setup-nanopi-reboot-required`, and `setup:konomitv` skips until the next boot.
- **Shell** — `~/.zshrc` / `~/.zshenv` are whole-file dotfiles, so `~/.zshrc` activates mise itself; `[bootstrap.mise_shell_activate]` only writes shims into `~/.zprofile` / bash files. Keep them in sync with setup-ubuntu.sh, leaving out desktop-only parts (VSCode, wine, rootless `DOCKER_HOST`, GPG agent).
- **Node.js** — from apt (system-wide), because KonomiTV runs under `sudo pm2`, which cannot see mise shims.
