zmodload zsh/zprof

export TERM=screen-256color
# If you come from bash you might have to change your $PATH.
export PATH=$HOME/.local/bin:/usr/local/bin:$HOME/go/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

export PULUMI_SKIP_UPDATE_CHECK=true

# Set name of the theme to load. Optionally, if you set this to "random"
# it'll load a random theme each time that oh-my-zsh is loaded.
# See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes
ZSH_THEME="amuse"
# Set list of themes to load
# Setting this variable when ZSH_THEME=random
# cause zsh load theme from this variable instead of
# looking in ~/.oh-my-zsh/themes/
# An empty array have no effect
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion. Case
# sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
#ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
COMPLETION_WAITING_DOTS="false"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# The optional three formats: "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
HIST_STAMPS="yyyy-mm-dd"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
  git
  fzf-tab
  ansible
)

export LANG=en_US.utf8
export LC_ALL=en_US.utf8

source $ZSH/oh-my-zsh.sh
# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# ssh
# export SSH_KEY_PATH="~/.ssh/rsa_id"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

alias ls="exa -lh"
alias fs="fzf -e --height 75% --layout reverse --info inline --border \
    --preview 'file {}' --preview-window down:1:noborder \
    --color 'fg:#bbccdd,fg+:#ddeeff,bg:#111111,preview-bg:#223344,border:#778899'"
alias fsp="fzf -e --preview 'bat --style=numbers --color=always --line-range :500 {}'"

alias tohex="printf '%x\n'"

# Terraform

function tf(){
  echo "Running tofu on workspace: $(tofu workspace show).">&2
  [[ -e .tofu-pre && -x .tofu-pre ]] && echo "Running tofu pre-hook...">&2 && source ./.tofu-pre>&2
  tofu $@
  [[ -e .tofu-post && -x .tofu-post ]] && echo "Running tofu post-hook...">&2 && source ./.tofu-post>&2
}

alias tfa='tf apply --var-file ./environments/$(tofu workspace show).tfvars'
alias tfp='tf plan --var-file ./environments/$(tofu workspace show).tfvars'
alias tfd='tf destroy --var-file ./environments/$(tofu workspace show).tfvars'
alias tfwl="tofu workspace list"
alias tfws="tofu workspace select"

#alias mc="mc --nosubshell"

[ -f $HOME/.fzf.zsh ] && source $HOME/.fzf.zsh

# Figlet font for custody demo client
cheat() { q="$1"; curl cheat.sh/$q }
b64d() { echo "$1" | base64 --decode }


# zsh-fzf-history-search
#zinit ice lucid wait'0'
#zinit light joshskidmore/zsh-fzf-history-search

# Ansible stuiff
export EDITOR=nvim
export VISUAL=nvim
export GPG_TTY=$(tty)
export TELEPORT_ADD_KEYS_TO_AGENT=no
export TELEPORT_LOGIN=root
export ANSIBLE_NOCOWS=1

# Set autocomplete color to teal
export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=6'

# Semantic versioning (from ChatGPT4)
#
function parse_version(){
  local version=${1#v}
  local major=${version%%.*}
  local minor_patch=${version#*.}
  local minor=${minor_patch%.*}
  local patch=${minor_patch#*.}
  echo $major $minor $patch
}

function create_version(){
  local increment=$1
  local last_tag=$(git describe --abbrev=0 --tags)
  local version=$(parse_version $last_tag)
  local major=$(echo $version | awk '{printf $1}')
  local minor=$(echo $version | awk '{printf $2}')
  local patch=$(echo $version | awk '{printf $3}')

  case $increment in
  "major")
    major=$((major+1))
    minor=0
    patch=0
    ;;
  "minor")
    minor=$((minor+1))
    patch=0
    ;;
  "patch")
    patch=$((patch+1))
    ;;
  esac

  local new_version="v$major.$minor.$patch"
  echo $new_version
}

function create_tag(){
  local new_version=$(create_version $1)

   # Confirmation
  read "yn?A new tag $new_version will be created. Do you want to proceed? (Y/n) "
  yn=${yn:-y} # Default value is 'y' if enter is pressed without an answer
  case $yn in
    [Yy]* ) 
      git tag $new_version
      git push --tags
      echo "Created new tag: $new_version"
      ;;
    * ) 
      echo "Aborted"
      ;;
  esac
}

alias gt-bump="create_tag"

echo "Preparing Teleport SSH..."
mkdir -p /root/.ssh
tsh config > /root/.ssh/config

echo "Preparing pre-commit hooks..."
cd /src
pre-commit install
pre-commit autoupdate
