# .config

Portable, XDG-based personal dotfiles: zsh, tmux, powerlevel10k, git, homebrew,
raycast, vscode. Self-contained — on any fresh machine `./setup.sh` gives a
working personal shell. Machine- or work-specific config layers on top through a
`zsh/rc.d` extension point, so this repo never needs to know those layers exist.

## Architecture

Three independent layers, composed by a bootstrap entrypoint — not by this repo:

1. **`.config` (this repo, public)** — the portable base. Sets up zsh (via
   `ZDOTDIR`), oh-my-zsh, powerlevel10k, tmux, homebrew, etc. Knows nothing about
   any employer, host, or private tooling.
2. **A private overlay (optional)** — e.g. work dotfiles. It installs its own
   zshrc as `~/.config/zsh/rc.d/50-*.zsh` and its aliases into
   `~/.config/aliases/`. Present only on machines where it has been set up.
3. **A bootstrap entrypoint** — clones layer 1 and runs its `setup.sh`, then
   clones layer 2 and runs its `setup.sh`. This is the *only* place the layers
   are composed. On a personal machine you run layer 1 alone and `rc.d` stays
   empty; everything still works.

The rule: dependencies point **up**, never down. The overlay and bootstrap know
about `.config`; `.config` knows about neither.

### Boot chain

```
zsh startup
  → /etc/zshenv                                  (system)
  → ~/.zshenv          (copy of zsh/.zshenv)     sets ZDOTDIR=~/.config/zsh
  → $ZDOTDIR/.zshrc    (symlink → this repo)     p10k, oh-my-zsh, plugins, then:
        for f in $ZDOTDIR/rc.d/*.zsh; do source $f; done   ← extension point
              └─ 50-*.zsh → (overlay) zshrc → overlay aliases + shell init
```

`~/.zshenv` is the load-bearing file. It is the one rc file zsh autoloads from
`$HOME`, and all it does is point `ZDOTDIR` at `~/.config/zsh` so every other rc
file lives under XDG paths. `setup.sh` copies it into `$HOME`. If a new shell
comes up with the wrong prompt and no custom config, check `echo $ZDOTDIR`
first — an empty value means `~/.zshenv` did not autoload and nothing downstream
will run.

## Layout

```
.
├── README.md                -> this doc
├── SECURITY.md
├── setup.sh                 -> symlinks/copies configs into place; creates rc.d
├── packages.sh              -> OS-aware package install (Homebrew on macOS, apt+source on Linux)
├── apple/apple.sh           -> macOS-only setup, run once per new mac
├── git/.gitconfig.personal  -> personal git identity
├── homebrew/
│   ├── Brewfile             -> full brew set
│   └── Brewfile-minimal     -> minimal set for remote machines
├── tmux/tmux.conf
├── vscode/software.json     -> extensions to install
├── raycast/                 -> raycast config
├── commands/                -> (deprecating) custom commands
└── zsh/
    ├── .zshenv              -> sets XDG + ZDOTDIR (copied to $HOME)
    ├── .zshrc               -> oh-my-zsh, p10k, sources rc.d/*.zsh
    ├── .zprofile
    ├── .p10k.zsh
    ├── oh-my-zsh/           -> installed by setup.sh
    └── rc.d/                -> extension point (created by setup.sh, populated
                                by overlays; empty on a personal machine)
```

`~/.config/aliases/` is created at setup time and holds alias files symlinked in
by an overlay; it is not tracked here.

## Setup

Personal machine (this repo only):

```
git clone https://github.com/sanathkumarbs/.config.git ~/personal/.config
~/personal/.config/setup.sh
```

This installs zsh/oh-my-zsh/p10k/plugins/tmux and creates the
`~/.config/zsh/rc.d` extension point. Open a new shell. Run it as your normal
user — `setup.sh` refuses to run as root (running it under `sudo` breaks file
ownership and is never needed).

Full machine (base + private overlay): run your bootstrap entrypoint, which
composes both layers in order.

## Adding a machine or work overlay

An overlay is any repo that drops a `*.zsh` into `~/.config/zsh/rc.d/`. Files are
sourced in lexical order, so prefix with a number (`50-…`) to control ordering.
The overlay's own `setup.sh` should symlink its zshrc in, e.g.:

```
ln -sf "$OVERLAY_DIR/zshrc" ~/.config/zsh/rc.d/50-work.zsh
```

That zshrc can then source aliases from `~/.config/aliases/`, load private shell
init, etc. Because `.config` only globs `rc.d/*.zsh`, an empty `rc.d` is a no-op
and the base stays fully functional on its own.

## Notes

- XDG base directories are set in `zsh/.zshenv`; `ZDOTDIR` redirects all zsh rc
  files under `~/.config/zsh`.
- The default branch is `main` — a fresh bootstrap clones `main`, so land changes
  there for them to reach new machines.
