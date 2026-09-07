# ~/.config/me/env.sh
# Single source of truth for the environment (currently: PATH) shared by every
# context: interactive shells (~/.bashrc), login shells, and GUI sessions
# (~/.profile, read by the GDM Xsession). Keep this POSIX sh and side-effect
# free of interactive-only setup so it is safe to source anywhere.

# Idempotent, dir-guarded helpers.
_path_prepend() { [ -d "$1" ] && case ":${PATH}:" in *":$1:"*) ;; *) PATH="$1:$PATH" ;; esac; }
_path_append() { [ -d "$1" ] && case ":${PATH}:" in *":$1:"*) ;; *) PATH="$PATH:$1" ;; esac; }

# High-precedence overrides (front of PATH). Prepend in lowest-priority-first
# order so the final front order is: /opt/nvim/bin, ~/.local/bin,
# ~/.local/kitty.app/bin, ~/tools/llvm/bin, ~/tools/cmake/bin, ~/.cargo/bin.
_path_prepend "$HOME/.cargo/bin"
_path_prepend "$HOME/tools/cmake/bin"
_path_prepend "$HOME/tools/llvm/bin"
_path_prepend "$HOME/.local/kitty.app/bin"
_path_prepend "$HOME/.local/bin"
_path_prepend "/opt/nvim/bin"

# Toolchains added after the system dirs (kept as trailing entries).
_path_append "$HOME/.zvm/bin"
_path_append "$HOME/.zvm/self"
_path_append "/usr/lib/postgresql/18/bin"
_path_append "$HOME/go/bin"
_path_append "/opt/nvim-linux-x86_64/bin"
_path_append "$HOME/.opencode/bin"
_path_append "/usr/local/go/bin"

export PATH

unset _path_prepend _path_append
