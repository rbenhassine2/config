# Dotfiles workflow

This repository is a **bare Git repository** stored at `~/.cfg` with the working
tree set to `$HOME` (the [Atlassian pattern](https://www.atlassian.com/git/tutorials/dotfiles)).

## The `config` alias

```sh
config() {
  /usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME "$@"
}
```

Use `config` instead of `git` for everything related to dotfiles:

```sh
config status
config add ~/.config/i3/config
config commit -m "..."
config push origin master
```

## Layout

- Everything tracked lives directly under `$HOME` (e.g. `.config/i3/config`, `tools/`).
- Machine-local runtime state (symlinks under `~/.config/systemd/user/default.target.wants/`,
  autorandr profiles) is **not** tracked.
- `status.showUntrackedFiles no` keeps `config status` clean.

## How the docs stay out of `$HOME`

`README.md` and the `wiki/` folder are tracked in the repo (so they render on
GitHub) but are marked with git's `skip-worktree` flag, which makes git treat
them as intentionally absent from the working tree. As a result they exist only
in the repository, never in `$HOME`.

To edit them, use the helper:

```sh
~/.local/bin/docs-edit.sh show   # materialize README + wiki in $HOME for editing
# ... edit, then commit:
config add README.md wiki && config commit -m "..."
~/.local/bin/docs-edit.sh hide   # re-skip and remove them from $HOME
```

You can also edit `README.md` / `wiki/*.md` directly on GitHub.

## New-machine setup

`~/.config/me/setup.sh` clones the repo, checks out the config (backing up any
conflicting files), applies the skip-worktree flags for the docs, and enables
the display-watchdog systemd user service.
