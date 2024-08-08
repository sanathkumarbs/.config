# .config
dotfiles for sanath using XDG Base Spec

## organization:

```
├── README.md                   -> this doc :) 
├── aliases                     -> dir to hold personal custom aliases
├── apple
│   └── apple.sh                -> apple specific setup, run only on new macs
├── commands                    -> will be deprecated, and, moved into aliases
├── git
│   └── .gitconfig.personal     -> personal sanathkumarbs gitconfig
├── homebrew
│   ├── Brewfile                -> brews that i love
│   └── Brewfile-minimal        -> minimal brew for remote machines
├── setup.sh                    -> setting up the configs by moving things to $HOME/.config 
├── vscode
│   └── software.json           -> extensions on vscode that i rely on
└── zsh
    ├── .p10k.zsh               -> powerlevel10k config
    ├── .zprofile               -> personal zsh configs
    ├── .zshenv                 -> personal zsh configs
    └── .zshrc                  -> personal zsh configs
```

## zsh setup notes:

Work dotfiles should be hosted at `$HOME/work/dotfiles` which will setup if they're found:

```
if [ -f "$HOME"/work/dotfiles/setup.sh ]; then
  echo "setting up work dotfiles... "
  # shellcheck source=/dev/null
  source "$HOME"/work/dotfiles/setup.sh
else
  echo "failed to setup work dotfiles, setup.sh not found in $HOME/work/dotfiles/"
fi
```

Additionally, work dotfiles should contain it's own `zshrc` config which will be sourced if present from the `zsh/.zshrc` present in this repo

```
if [[ -f ~/work/dotfiles/zshrc ]]; then
  source ~/work/dotfiles/zshrc
fi

```

how `$HOME/work/dotfiles` should be organized

```
.
├── .bash_profile.atlas.aliases     -> work specific bash aliases
├── README.md                       -> document! document!
├── setup.sh                        -> setting up aliases or any configs into $HOME/.config 
└── zshrc                           -> work specific zshrc configs
```
