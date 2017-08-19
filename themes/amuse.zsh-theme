# vim:ft=zsh ts=2 sw=2 sts=2

rvm_current() {
  rvm current 2>/dev/null
}

rbenv_version() {
  rbenv version 2>/dev/null | awk '{print $1}'
}

PROMPT='
%{$fg_bold[blue]%}${PWD/#$HOME/~}%{$reset_color%}$(git_prompt_info)
$ '

# Must use Powerline font, for \uE0A0 to render.
ZSH_THEME_GIT_PROMPT_PREFIX=" on %{$fg[green]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[red]%}!"
ZSH_THEME_GIT_PROMPT_UNTRACKED="%{$fg[green]%}?"
ZSH_THEME_GIT_PROMPT_CLEAN=""

function amuse_git_status() {
  if [ -e ~/.rvm/bin/rvm-prompt ]; then
    RPROMPT='%{$fg_bold[red]%}‹$(rvm_current)›%{$reset_color%}'
  else
    if which rbenv &> /dev/null; then
      RPROMPT='%{$fg_bold[red]%}$(rbenv_version)%{$reset_color%}'
    fi
  fi
  return
}

ASYNC_PROC=0

function precmd() {
  function async() {
    # save to temp file
    printf "%s" "%{$fg_bold[red]%}$(rbenv_version)%{$reset_color%}" > "/tmp/zsh_prompt_$$"

    # signal parent
    kill -s USR1 $$
  }

  # do not clear RPROMPT, let it persist

  # kill child if necessary
  if [[ "${ASYNC_PROC}" != 0 ]]; then
    kill -s HUP $ASYNC_PROC >/dev/null 2>&1 || :
  fi

  # start background computation
  async &!
  ASYNC_PROC=$!
}

function TRAPUSR1() {
  # read from temp file
  RPROMPT="$(cat /tmp/zsh_prompt_$$)"

  # reset proc number
  ASYNC_PROC=0

  # redisplay
  zle && zle reset-prompt
}
