# https://scriptingosx.com/2019/07/moving-to-zsh-part-5-completions/

# Speed up zsh:
# https://blog.mattclemente.com/2020/06/26/oh-my-zsh-slow-to-load.html#a-note-on-profiling-with-zshzprof
# https://medium.com/@dannysmith/little-thing-2-speeding-up-zsh-f1860390f92
# zmodload zsh/zprof

# For detailed trace: zsh -lxv

function startTimer(){
  timer=$(($(gdate +%s%N)/1000000))
}
function echoTimer(){
  if [ "$timer" ]; then
    now=$(($(gdate +%s%N)/1000000))
    elapsed=$(($now-$timer))
    echo "$PWD $elapsed: $1" >&2
    timer=$now
  fi
}
# startTimer

# If you come from bash you might have to change your $PATH.
# put gnu-getopt first
export PATH="/usr/local/opt/gnu-getopt/bin:$PATH"
export PATH="/usr/local/opt/make/libexec/gnubin:$PATH"
# python poetry
export PATH="$HOME/.poetry/bin:$PATH"
# my scripts take precendence
export PATH="$HOME/bin:$PATH"

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
# ZSH_THEME="myaussiegeek"
# ZSH_THEME="avit"
ZSH_THEME="powerlevel10k/powerlevel10k"
# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in ~/.oh-my-zsh/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# To manually update, run: upgrade_oh_my_zsh

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to automatically update without prompting.
# DISABLE_UPDATE_PROMPT="true"

# Uncomment the following line to change how often to auto-update (in days).
export UPDATE_ZSH_DAYS=15

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS=true

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# called when rendering command prompt
DISABLE_AUTO_TITLE="true"
function precmd () {
  if [ "$MY_WINDOWTITLE" ]; then
    echo -ne "\033]0;${MY_WINDOWTITLE}\007"
  else
    local SHORT_PWD=`echo ${PWD/$HOME/\~} | sed 's:\([^/][^/][^/]\)[^/]*/:\1/:g'`
    echo -ne "\033]0;${SHORT_PWD}\007"
  fi
}

# Uncomment the following line to enable command auto-correction.
#ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
HIST_STAMPS="%m/%d %H:%M"

# http://www.bash2zsh.com/zsh_refcard/refcard.pdf
setopt HIST_EXPIRE_DUPS_FIRST    # Expire duplicate entries first when trimming history.
setopt HIST_FIND_NO_DUPS         # Do not display a line previously found when searching.
setopt HIST_REDUCE_BLANKS        # removes blank lines from history
# http://zsh.sourceforge.net/Doc/Release/Options.html
setopt HIST_SAVE_NO_DUPS        # When writing out the history file, duplicate are omitted
#unsetopt EXTENDED_HISTORY       # Save each command’s beginning timestamp
setopt HIST_IGNORE_ALL_DUPS     # older duplicate command is removed
setopt HIST_IGNORE_DUPS         # ignore duplicates of the previous event
setopt HIST_IGNORE_SPACE        # when the first character on the line is a space

# hook function "Executed when a history line has been read interactively, but before it is executed."
zshaddhistory() {
    local line=${1%%$'\n'}
    local cmd=${line%% *}
    # Only those that satisfy all of the following conditions are added to the history
    [[ ${#line} -ge 5
       && ${cmd} != ll
       && ${cmd} != l
    ]]
}
zshaddhistory

# http://zsh.sourceforge.net/Doc/Release/Options.html
#setopt CORRECT    # shell will make a guess of what you meant to type and ask whether you want do

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in ~/.oh-my-zsh/plugins/*
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
	# common-aliases
	history
	zsh-interactive-cd
	# git
	sublime
	#codeclimate
	zsh-syntax-highlighting
	# slow:
	zsh-autosuggestions
	# slow:
	rbenv
	evalcache
  # Unknown:
  asdf
)

# This speeds up pasting w/ autosuggest
# https://github.com/zsh-users/zsh-autosuggestions/issues/238#issuecomment-389324292
pasteinit() {
  OLD_SELF_INSERT=${${(s.:.)widgets[self-insert]}[2,3]}
  zle -N self-insert url-quote-magic # I wonder if you'd need `.url-quote-magic`?
}
pastefinish() {
  zle -N self-insert $OLD_SELF_INSERT
}
zstyle :bracketed-paste-magic paste-init pasteinit
zstyle :bracketed-paste-magic paste-finish pastefinish

echoTimer "Before oh-my-zsh.sh"

source $ZSH/oh-my-zsh.sh
echoTimer "After oh-my-zsh.sh"

# User configuration

# https://superuser.com/questions/446594/separate-up-arrow-lookback-for-local-and-global-zsh-history
# https://superuser.com/questions/714412/zsh-or-maybe-oh-my-zsh-history-gets-confused-with-multi-line-commands
bindkey "OA" up-line-or-local-history
bindkey "[A" up-line-or-local-history
bindkey "OB" down-line-or-local-history
bindkey "[B" down-line-or-local-history

up-line-or-local-history() {
    zle set-local-history 1
    zle up-line-or-search
    zle set-local-history 0
}
zle -N up-line-or-local-history
down-line-or-local-history() {
    zle set-local-history 1
    zle down-line-or-search
    zle set-local-history 0
}
zle -N down-line-or-local-history

bindkey "^[[1;5A" up-line-or-history    # [CTRL] + Cursor up
bindkey "^[[1;5B" down-line-or-history  # [CTRL] + Cursor down

echoTimer "bindkey"

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

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.

export H=$HOME
export MY_BIN=$HOME/bin

if [ "$MY_BIN" ]; then
	export MY_BINSRC="$MY_BIN/src" #dir of files to be sourced automatically if executable
fi

export MY_NOBACKUP=$HOME/NOBACKUP
[ -d "$MY_NOBACKUP" ] || mkdir "$MY_NOBACKUP"

# used by many apps (e.g. gs, ps2pdf, gksudo)
# must use actual resolved directory since root will not have permissions to a mounted home directory or its subdirs
if [ -e "$HOME/.my_links/tempDir" ]; then
	cd -P "$HOME/.my_links/tempDir"
	export TEMP=`pwd -P`
	cd - > /dev/null
fi
[ "$TEMP" ] || export TEMP="$MY_NOBACKUP/var/tmp"
# used by mutt
export TMPDIR=$TEMP
export TMP=$TEMP
[ -d "$TMP" ] || mkdir -pv "$TMP"

if [ -z "$MY_TRASH" ] ; then
	[ -e "$HOME/.my_links" ] && export MY_TRASH=$HOME/.my_links/trashDir
	[ -e "$MY_TRASH" ] || export MY_TRASH="$TMP"
fi
echoTimer "TEMP and MY_TRASH"


export CLICOLOR=1
export BROWSER=open
export VISUAL="subl --wait"
export EDITOR=vim
export XIVIEWER=open
export LESS="-F -X $LESS"

# nnn
export NNN_BMS='s:~/Desktop;d:~/Documents;D:~/Downloads/;a:~/DockApps;v:~/dev'

# don't use pager for git grep
# see ~/.gitconfig instead: export GIT_PAGER=''

alias dateStr='date +%Y-%m-%d-%T'
source ~/.my_rc/bin/src/funcs.src

#zsh uses the path variable # alias path='echo -e ${PATH//:/\\n}'
alias sdkman='source "$HOME/.sdkman.src"'

alias dockr_jupyter='echo "Running on port 8890"; docker run -p 8890:8888 -v `pwd`:/home/jovyan/on_host jupyter/scipy-notebook'
alias dockr_jupyter_ruby='echo "Running on port 8891"; docker run -p 8891:8888 -v `pwd`:/home/jovyan/on_host rubydata/datascience-notebook'
source ~/.alias-$HOST
echoTimer "aliases"

# to hide the “user@hostname” info when you’re logged in as yourself on your local machine
#prompt_context(){}
#export PROMPT="$fg_bold[blue][ $fg[red]%t $fg_bold[blue]] $fg_bold[blue] [ $fg[red]%~ $(git_prompt_info)$fg[yellow]$(rvm_prompt_info)$fg_bold[blue] ]$reset_color
# $ "

# Reminder: kitty.conf: macos_option_as_alt left
bindkey '\M-.' insert-last-word
# See kitty.conf: bindkey '\C-.' insert-last-word

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
echoTimer "fzf"

sup(){
	conda_
	python3 ~/bin/clickup-export.py "$@" | pbcopy
}

# replaced with asdf-vm
# java(){
# 	echo "(lazy loading) Enabling SDKMAN"
# 	sdkman
# 	echo "(loaded)"
# 	unset -f java
# 	java -version
# 	[ "$1" ] && java "$@"
# }

miniconda_(){
	echo "(lazy loading) Enabling miniconda"
	source ~/miniconda3/autosource
	echo "(loaded miniconda)"
	unset -f miniconda_
	conda env list
	[ "$1" ] && conda "$@"
}
conda_(){
	echo "(lazy loading) Enabling Anaconda"
	source ~/anaconda3/autosource
	echo "(loaded Anaconda)"
	unset -f conda_
	conda env list
	[ "$1" ] && conda "$@"
}
go_(){
	echo "(lazy loading) Enabling Go lang"
	source ~/.golangrc
	echo "(loaded Go lang)"
	unset -f go_
	[ "$1" ] && go "$@"
}
nvm_(){
  export NVM_DIR="$HOME/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
  [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
}

# icu4c is keg-only, which means it was not symlinked into /usr/local,
# because macOS provides libicucore.dylib (but nothing else).
#
# If you need to have icu4c first in your PATH run:
#   echo 'export PATH="/usr/local/opt/icu4c/bin:$PATH"' >> ~/.zshrc
#   echo 'export PATH="/usr/local/opt/icu4c/sbin:$PATH"' >> ~/.zshrc
#
# For compilers to find icu4c you may need to set:
#   export LDFLAGS="-L/usr/local/opt/icu4c/lib"
#   export CPPFLAGS="-I/usr/local/opt/icu4c/include"
#
# For pkg-config to find icu4c you may need to set:
#   export PKG_CONFIG_PATH="/usr/local/opt/icu4c/lib/pkgconfig"

#used for installing iruby for Jupyter
#export GEM_HOME="$HOME/.gem"
#PATH=$GEM_HOME/bin:$PATH

echoTimer "lazy functions"

# startTimer
# https://sw.kovidgoyal.net/kitty/index.html#zsh
# https://gist.github.com/ctechols/ca1035271ad134841284#gistcomment-2308206
setopt extendedglob
autoload -Uz compinit
echoTimer "autoload compinit"
for dump in ~/.zcompdump(N.mh+24); do
  compinit
done
compinit -C
echoTimer "compinit"

# Completion for kitty
# kitty + complete setup zsh | source /dev/stdin
# echoTimer "autocompletions: kitty"

heroku_(){
	# heroku autocomplete setup
	HEROKU_AC_ZSH_SETUP_PATH=/Users/yoomlam/Library/Caches/heroku/autocomplete/zsh_setup && test -f $HEROKU_AC_ZSH_SETUP_PATH && source $HEROKU_AC_ZSH_SETUP_PATH;
}

echoTimer "Done zshrc"

c

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# https://gist.github.com/protosam/11800faea25a3f89af9ece4f11c72f1d#using-docker-cli
# minikube status > /dev/null && eval $(minikube docker-env)

# Instead of using the asdf zsh plugin
# https://github.com/ohmyzsh/ohmyzsh/issues/10484#issuecomment-997545691
unset ASDF_DIR
source $(brew --prefix asdf)/libexec/asdf.sh
