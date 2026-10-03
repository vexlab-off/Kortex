# ==============================================================================
# Kortex Environment & Shell Additions (Zsh)
# ==============================================================================

if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
  export PATH="$HOME/.local/bin:$PATH"
fi

export KORTEX_PATH="${OMARCHY_PATH:-/usr/share/omarchy}"
alias kortex="$HOME/.local/bin/kortex"
alias k='kortex'
alias a='kortex-agent --inline'

if [[ -t 1 && -o interactive ]]; then
  fastfetch 2>/dev/null || true
fi
