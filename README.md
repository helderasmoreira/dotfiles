# dotfiles

Config for various tools I use in my workflow. `install.sh` symlinks each file into place, so edits on the machine land in this repo.

## Notes for future self or 🤖

> [!IMPORTANT]
> You'll probably want to interact with GitHub, so do this first: create an SSH key at `~/.ssh/id_ed25519` and add it to GitHub.

1. Install [Homebrew](https://brew.sh) and [oh-my-zsh](https://ohmyz.sh). oh-my-zsh has to come before `install.sh`, because its installer overwrites `~/.zshrc`.
2. Clone this repo to `~/Work/dotfiles`. `ai/claude.md` imports `~/Work/dotfiles/ai/shared.md` by that path.
3. Run `brew bundle --file brew/Brewfile`. Casks that install with `sudo` need admin rights.
4. Run `./install.sh`. A file already in place with different content is moved to `<name>.bak`. The script is safe to rerun.
5. Create `~/.zshrc.local` for anything machine-specific or secret. `.zshrc` sources it last.
