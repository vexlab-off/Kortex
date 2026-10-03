# ==============================================================================
# Kortex Environment & Shell Additions (Bash)
# ==============================================================================

# Ensure ~/.local/bin is in PATH
if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
  export PATH="$HOME/.local/bin:$PATH"
fi

# Kortex environment and aliases
export KORTEX_PATH="${OMARCHY_PATH:-/usr/share/omarchy}"
alias kortex="$HOME/.local/bin/kortex"
alias k='kortex'
alias a='kortex-agent --inline'

# Auto-run fastfetch on terminal startup and after clear
if [[ -t 1 && $- == *i* ]]; then
  fastfetch 2>/dev/null || true

  clear() {
    command clear "$@"
    fastfetch 2>/dev/null || true
  }
  bind -x '"\C-l": clear' 2>/dev/null || true
fi
