# Philipp Bucher
# This file contains "convenience" aliases that I use across systems

# Philipp Bucher, part of "bash scripts"

#******** overriding stuff from .bashrc****************************************
# enlarge history
HISTSIZE=5000 #1000
HISTFILESIZE=10000 #2000

alias ll='ls -alFh' # display the file sizes in readable format

# change colors
PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u:\[\033[01;34m\]\w\[\033[00m\]\$ '
#******************************************************************************

# System aliases
PROMPT_DIRTRIM=2 # show parent and current directory

alias ..="cd .."
alias ...="cd ../.."
alias sort_size='du -sh * | sort -rh'
