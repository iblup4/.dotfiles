# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

# Path to your Oh My Zsh installation.
export ZSH="${ZSH:-$HOME/.oh-my-zsh}"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time Oh My Zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
# ZSH_THEME="robbyrussell"
function git_branch_name()
{
  branch=$(git symbolic-ref HEAD 2> /dev/null | awk 'BEGIN{FS="/"} {print $NF}')
  if [[ $branch == "" ]];
  then
    :
  else
    echo '('$branch') '
  fi
}

PROMPT='%F{green}%*%f %F{blue}%~%f %F{red}${vcs_info_msg_0_}$(git_branch_name)%f$ '
# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.

export NVM_DIR="${NVM_DIR:-$HOME/.nvm}"
# Initialize NVM on the first Node command instead of delaying every shell.
zstyle ':omz:plugins:nvm' lazy yes
plugins=(git nvm)

if [[ -r "$ZSH/oh-my-zsh.sh" ]]; then
  source "$ZSH/oh-my-zsh.sh"
fi
setopt prompt_subst

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
# fi

# Compilation flags
# export ARCHFLAGS="-arch $(uname -m)"

# Set personal aliases, overriding those provided by Oh My Zsh libs,
# plugins, and themes. Aliases can be placed here, though Oh My Zsh
# users are encouraged to define aliases within a top-level file in
# the $ZSH_CUSTOM folder, with .zsh extension. Examples:
# - $ZSH_CUSTOM/aliases.zsh
# - $ZSH_CUSTOM/macos.zsh
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

b() {
  if [[ -f Justfile || -f justfile ]]; then
    if command -v just >/dev/null; then
      command just "$@"
    else
      echo "b: Justfile found but 'just' is not installed" >&2
      return 1
    fi
  elif [[ -f Makefile || -f makefile ]]; then
    command make "$@"
  else
    echo "b: no Justfile or Makefile found" >&2
    return 1
  fi
}

alias m="b"

export EDITOR='nvim'
alias vim="nvim"
alias v="nvim"

# Keep PATH entries unique, including when this file is sourced again.
typeset -U path PATH
dotfiles_paths=()
case "$OSTYPE" in
  darwin*)
    dotfiles_paths=(/usr/local/sbin /usr/local/bin /opt/homebrew/sbin /opt/homebrew/bin)
    ;;
  linux*)
    dotfiles_paths=(/snap/bin /home/linuxbrew/.linuxbrew/sbin /home/linuxbrew/.linuxbrew/bin)
    ;;
esac
for dotfiles_bin in "${dotfiles_paths[@]}" "$HOME/.cargo/bin" "$HOME/.local/bin"; do
  if [[ -d "$dotfiles_bin" ]]; then
    path=("$dotfiles_bin" "${path[@]}")
  fi
done
unset dotfiles_bin dotfiles_paths
export PATH

# Prefer an existing Conda installation; skip initialization when it is absent.
dotfiles_conda="${CONDA_EXE:-$HOME/.miniconda3/bin/conda}"
if [[ ! -x "$dotfiles_conda" ]]; then
  dotfiles_conda="${commands[conda]:-}"
fi
if [[ -x "$dotfiles_conda" ]]; then
  if dotfiles_conda_setup="$("$dotfiles_conda" shell.zsh hook 2>/dev/null)"; then
    eval "$dotfiles_conda_setup"
  elif [[ -r "${dotfiles_conda:h:h}/etc/profile.d/conda.sh" ]]; then
    source "${dotfiles_conda:h:h}/etc/profile.d/conda.sh"
  else
    path=("${dotfiles_conda:h}" "${path[@]}")
  fi
fi
unset dotfiles_conda dotfiles_conda_setup

bindkey '^[[1;9C' forward-word
bindkey '^[[1;9D' backward-word
# belt-and-suspenders in case it's actually 1;3 in some contexts
bindkey '^[[1;3C' forward-word
bindkey '^[[1;3D' backward-word

# Machine-specific settings take precedence over the shared configuration.
if [[ -r "$HOME/.zshrc.local" ]]; then
  source "$HOME/.zshrc.local"
fi
