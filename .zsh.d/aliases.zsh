alias reshell='exec $SHELL -l'

if (( $+commands[eza] )); then
  alias ls='eza --icons --group-directories-first --git'
  alias ll='eza --icons --group-directories-first --git -hla'
  alias lt='eza --icons --group-directories-first --git -hla --sort=modified'
  alias ltr='eza --icons --group-directories-first --git -hla --sort=modified --reverse'
  alias ltree='eza --icons --tree --level=2'
else
  alias ls='ls -GF'
  alias ll='ls -lhF'
  alias lt='ls -R'
fi

if (( $+commands[delta] )); then
  alias gd='git diff | delta'
  alias gl='git log -p | delta'
fi

