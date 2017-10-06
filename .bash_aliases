# Philipp Bucher
# customized .bash_aliases, to be used with .bashrc

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

# Program aliases
alias formulacollection='evince ~/Dropbox/utilities/FormulaCollection/formulaCollection.pdf &'

alias gid13="~/software/GiD/gid13.0.2-x64/gid"
alias gid13d="~/software/GiD/gid13.1.8d-x64/gid"

alias salome="~/software/SALOME/SALOME-8.3.0-UB16.04/salome"

alias lrz_sync_share="sh /usr/share/LRZ_Sync_Share/LRZ_Sync_Share-Client.sh"

alias valgrind='/home/philippb/software/Valgrind/valgrind-3.12.0_install/bin/valgrind'

alias pythonconsole="ipython3"

alias dropboxsync="~/scripts/dropbox.sh"

alias backup_lrz="/opt/tivoli/tsm/client/ba/bin/dsmj"

alias startOpenMPIserver="ompi-server -r ~/.ompi_server.port && echo Started ompi server"

alias salome_kratos_converter="python3 ~/software/SALOME_Kratos_Converter/converter_salome_kratos.py"

alias connect_headphones="python3 ~/scripts/a2pd.py 04:5D:4B:16:56:EC"
#https://gist.github.com/pylover/d68be364adac5f946887b85e6ed6e7ae
#https://askubuntu.com/questions/910501/udev-rule-to-run-python-script/912838#912838

# remove annoying warnings in terminal
alias calculator='gnome-calculator &> /dev/null'
alias gedit='gedit &> /dev/null'
alias kate='kate &> /dev/null'
alias virtualbox='virtualbox &> /dev/null'

ompsetthreads() {
    if [[ $# = 0 ]]; then
        export OMP_NUM_THREADS=1 && echo "No input, setting 1 thread"
    else
        export OMP_NUM_THREADS=$1 && echo "Set $1 OpenMP thread"
    fi
}
export -f ompsetthreads

export OMP_NUM_THREADS=1 # setting the number of OMP threads to one on shell startup

alias ompgetthreads='echo "Using $OMP_NUM_THREADS OpenMP threads"'

# Load Alias definitions for software (Kratos, Empire, ...).

if [ -f ~/.bash_software ]; then
    . ~/.bash_software
fi


