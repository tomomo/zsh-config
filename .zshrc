# ==============================================================================
# 0. 初期設定
#
# /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
# brew install zoxide mise fzf fd bat
# brew install zsh-autosuggestions zsh-syntax-highlighting
#
# ==============================================================================

# ==============================================================================
# 1. 基本設定
# ==============================================================================
typeset -U fpath path
setopt ignore_eof no_beep nolistbeep print_eight_bit extended_glob
setopt prompt_subst
setopt interactive_comments

# カラー設定
export CLICOLOR=1
export LSCOLORS=Gxfxcxdxbxegedabagacad
alias ls='ls -G'

# ==============================================================================
# 2. 履歴管理
# ==============================================================================
HISTFILE="${ZDOTDIR:-$HOME}/.zsh_history"
HISTSIZE=5000
SAVEHIST=1000000
setopt share_history append_history inc_append_history
setopt hist_ignore_all_dups hist_ignore_space hist_reduce_blanks hist_save_no_dups

# ==============================================================================
# 3. 外部ツール & 補完準備
# ==============================================================================
HOMEBREW_PREFIX="/opt/homebrew"
export PATH="${HOMEBREW_PREFIX}/bin:${HOMEBREW_PREFIX}/sbin:$PATH"

# --- 補完の場所を compinit 前にすべて登録 ---
if [[ -d "${HOMEBREW_PREFIX}/share/zsh/site-functions" ]]; then
  fpath=("${HOMEBREW_PREFIX}/share/zsh/site-functions" $fpath)
fi

if (( $+commands[zoxide] )); then
  eval "$(zoxide init zsh)"
fi

if (( $+commands[mise] )); then
  eval "$(mise activate zsh)"
fi

[[ -d "${ZDOTDIR:-$HOME}/completions" ]] && fpath=("${ZDOTDIR:-$HOME}/completions" $fpath)

autoload -Uz vcs_info
zstyle ':vcs_info:git:*' formats '(%b)'
zstyle ':vcs_info:*' enable git
precmd() { vcs_info }

zstyle ':completion:*' cache-path "${ZDOTDIR:-$HOME}/.zcompcache"
zstyle ':completion:*' use-cache on
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*:default' menu select=2

# --- 補完の初期化 ---
ZSH_COMPDUMP="${ZDOTDIR:-$HOME}/.zcompdump"
autoload -Uz compinit
compinit -u -d "$ZSH_COMPDUMP"

# ==============================================================================
# 4. fzf 設定
# ==============================================================================
if (( $+commands[fzf] )); then
  source <(fzf --zsh)
  if (( $+commands[fd] )); then
    export FZF_DEFAULT_COMMAND='fd --type f --strip-cwd-prefix --hidden --follow --exclude .git'
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
    export FZF_ALT_C_COMMAND='fd --type d --strip-cwd-prefix --hidden --exclude .git'
    export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border --inline-info \
      --bind 'ctrl-j:down,ctrl-k:up,ctrl-]:toggle-preview'"
    if (( $+commands[bat] )); then
      export FZF_CTRL_T_OPTS="--preview 'bat --color=always --style=numbers --line-range :250 {}' --preview-window hidden"
    fi
  fi
fi

# ==============================================================================
# 5. プロンプト & エイリアス
# ==============================================================================
PROMPT='%F{cyan}%n@%m %F{yellow}%~ %F{magenta}${vcs_info_msg_0_}%f
%# '

#compdef _git-lfs git-lfs git=lfs

if [ -d "${ZDOTDIR:-$HOME}/.zsh.d" ]; then
  for file in "${ZDOTDIR:-$HOME}/.zsh.d"/*.zsh; do
    [ -r "$file" ] && source "$file"
  done
  unset file
fi

# ==============================================================================
# 6. 軽量プラグイン (必ず最後に)
# ==============================================================================
[[ -f "${HOMEBREW_PREFIX}/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ]] && \
  source "${HOMEBREW_PREFIX}/share/zsh-autosuggestions/zsh-autosuggestions.zsh"

[[ -f "${HOMEBREW_PREFIX}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]] && \
  source "${HOMEBREW_PREFIX}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

