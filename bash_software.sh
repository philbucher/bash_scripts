export OMP_NUM_THREADS=2 # setting the number of OMP threads to one on shell startup

ompsetthreads() {
    if [[ $# = 0 ]]; then
        export OMP_NUM_THREADS=1 && echo "No input, setting 1 thread"
    else
        export OMP_NUM_THREADS=$1 && echo "Set $1 OpenMP thread"
    fi
}
export -f ompsetthreads

alias ompgetthreads='echo "Using $OMP_NUM_THREADS OpenMP threads"'

runvalgrind() {
    local valgrind_options="--leak-check=full --show-leak-kinds=all --track-origins=yes"
    eval local valgrind_out_file="valgrindout_$1.log"

    echo "===== VALGRIND ====="
    echo "Command: $1"
    echo "with options: $valgrind_options"
    echo "Valgrind output written to \"$valgrind_out_file\""
    sleep 0.3

    valgrind $valgrind_options ./$1  "${@:2}" 2> $valgrind_out_file # passing all the arguments 
}

gdbmpipython3() {
    if [[ $# < 2 ]]; then
        echo "At least inputfile and number of processes have to be given"
        return 1
    else
        if ! [[ $2 =~ ^[0-9]+$ ]] # checking if the second argument is an integer
            then
                throwerror "the second argument has to be the number of processes"
        fi

        echo "===== gdb python3 mpi execution ====="
        echo "with $2 processes"

        local omp_num_threads=$OMP_NUM_THREADS
        export OMP_NUM_THREADS=1

        mpiexec -np $2 xterm -hold -fa 'Monospace' -fs 12 -e gdb -ex run --args python3 $1 "${@:3}" # passing all the arguments

        export OMP_NUM_THREADS=$omp_num_threads
    fi
}
export -f gdbmpipython3
