# Philipp Bucher, part of "bash scripts"

alias compilekratos="kratoscompilation serial release $1"
alias compilekratosrelwdbg="kratoscompilation serial relwdbg $1"
# alias compilekratosdebug="kratoscompilation serial debug $1" # usually not used
alias compilekratosfulldebug="kratoscompilation serial fulldebug $1"
alias compilekratossuperdebug="kratoscompilation serial superdebug $1"

alias compilekratosmpi="kratoscompilation mpi release $1"
alias compilekratosmpirelwdbg="kratoscompilation mpi relwdbg $1"
# alias compilekratosmpidebug="kratoscompilation mpi debug $1" # usually not used
alias compilekratosmpifulldebug="kratoscompilation mpi fulldebug $1"
# the following is deactivated bcs it has problems with trilinos, see https://github.com/KratosMultiphysics/Kratos/issues/715
#alias compilekratosmpisuperdebug="kratoscompilation mpi superdebug $1"


setupkratosenv() {
    if [[ $# = 1 ]]; then
        if [[ -z "${KRATOS_PATH_ENV}" ]]; then
            export KRATOS_PATH_ENV=$1

            if [[ -z "${PYTHONPATH}" ]]; then # to avoid problems with empty PYTHONPATHSs
                export PYTHONPATH=$1"/install"
            else
                export PYTHONPATH=$1"/install":$PYTHONPATH
            fi

            if [[ -z "${LD_LIBRARY_PATH}" ]]; then # to avoid problems with empty LD_LIBRARY_PATHs
                export LD_LIBRARY_PATH=$1"/install/libs"
            else
                export LD_LIBRARY_PATH=$1"/install/libs":$LD_LIBRARY_PATH
            fi
            printinfo "Started Kratos $1"
        else
            throwerror "Kratos was already set at $KRATOS_PATH_ENV!"
            return 1
        fi
    else
        echo "Please provide 1 argument only!"
        return 1
    fi
}
export -f setupkratosenv


checkforkratos() {
if [[ -z "${KRATOS_PATH_ENV}" ]]; then
    throwerror "The Kratos Environment is not set!"
fi
}
export -f checkforkratos


deletekratoslibs() {
    checkforkratos

    echo -e "\e[1;43m Removing Kratos libraries ... \e[0m"
    local install_dir="${KRATOS_PATH_ENV}/install"
    local compilation_info="${KRATOS_PATH_ENV}/.kratoscompilation.info"
    if [ -d "$install_dir" ]; then
        rm -r "$install_dir"
    fi
    if [ -f "$compilation_info" ]; then
        rm "$compilation_info"
    fi

    find ${KRATOS_PATH_ENV} -name "*.pyc" -type f -delete
    find ${KRATOS_PATH_ENV} -name "*.time" -type f -delete
}
export -f deletekratoslibs


kratoscompilation() {
    checkforkratos

    local start_time=`date +%s`
    if [[ $# < 2 ]]; then
        echo "Not enough input arguments"
        return 1
    fi

    local base_dir=$(pwd)

    export KRATOS_SOURCE=${KRATOS_PATH_ENV}
    export KRATOS_APP_DIR="${KRATOS_SOURCE}/applications"
    export KRATOS_APPLICATIONS=""
    export KRATOS_CMAKE_CXX_FLAGS=""

    if [ ! -f ${KRATOS_PATH_ENV}/kratos_configure_sh_general.sh ]; then
        throwerror "No \"kratos_configure_sh_general.sh\" available!"
    fi

    cp ${KRATOS_PATH_ENV}/kratos_configure_sh_general.sh ${KRATOS_PATH_ENV}/.configure_sh_temp.txt

    if [[ $1 == "serial" ]]; then
        export KRATOS_CMAKE_OPTIONS_FLAGS="-DUSE_MPI=OFF"
    elif [[ $1 == "mpi" ]]; then
        echo ""
        export KRATOS_APPLICATIONS="${KRATOS_APPLICATIONS}${KRATOS_APP_DIR}/MetisApplication;"
        export KRATOS_APPLICATIONS="${KRATOS_APPLICATIONS}${KRATOS_APP_DIR}/TrilinosApplication;"
        export KRATOS_CMAKE_OPTIONS_FLAGS="-DUSE_MPI=ON"
    else
       echo "Input argument 1 - \"$1\" - not valid, choose \"serial\" or \"mpi\""
       exit 0
    fi

    if [[ $2 == "release" ]]; then
        export KRATOS_BUILD_TYPE="Release"
        local mode="Release"
    elif [[ $2 == "debug" ]]; then
        export KRATOS_BUILD_TYPE="Debug"
        local mode="Debug"
    elif [[ $2 == "fulldebug" ]]; then
        export KRATOS_BUILD_TYPE="FullDebug"
        local mode="FullDebug"
    elif [[ $2 == "superdebug" ]]; then
        export KRATOS_BUILD_TYPE="FullDebug"
        export KRATOS_CMAKE_CXX_FLAGS="-D_GLIBCXX_DEBUG"
        # now adding the "SuperDebug" option (use carfully, see https://github.com/KratosMultiphysics/Kratos/issues/715)
        local mode="SuperDebug"
    elif [[ $2 == "relwdbg" ]]; then
        export KRATOS_BUILD_TYPE="RelWithDebInfo"
        local mode="RelWithDebInfo"
    else
       echo "Input argument 2 - \"$2\" - not valid, choose \"release\", \"debug\", \"relwdbg\", \"fulldebug\", \"superdebug\""
       return 0
    fi

    local cmake_folder="cmake_build_$1_$2"
    eval local build_dir="${KRATOS_PATH_ENV}/$cmake_folder"
    export KRATOS_BUILD=$build_dir

    if [ ! -d "$build_dir" ]; then
        mkdir $build_dir
        printinfo "Build Directory $build_dir was created"
    fi

    if [[ $3 == "clean" ]]; then
        printinfo "Performing clean compilation"
        rm -r "$build_dir"
        mkdir "$build_dir"
    fi

    cd "$build_dir" &> /dev/null

    cp ${KRATOS_PATH_ENV}/.configure_sh_temp.txt configure.sh
    rm ${KRATOS_PATH_ENV}/.configure_sh_temp.txt

    getactivebranch compiled_branch

    echo -e "compiling Kratos Path: \t\e[1;48;5;4m ${KRATOS_PATH_ENV} \e[0m"
    echo -n "compiling branch: "
    echo -e "\t\e[1;44m ${compiled_branch} \e[0m"

    echo -n "compiling mode: "
    echo -e "\t\e[1;44m $1 \e[0m"

    echo -n "compiling version: "
    echo -e "\t\e[1;44m ${mode} \e[0m \n"

    deletekratoslibs

    if \time -f%E -o ~/.tmp.txt sh configure.sh ; then
        echo "${compiled_branch}" > ${KRATOS_PATH_ENV}/.kratoscompilation.info
        echo "$1" >> ${KRATOS_PATH_ENV}/.kratoscompilation.info
        echo "$mode" >> ${KRATOS_PATH_ENV}/.kratoscompilation.info
        echo -e "\e[1;42m Compilation Successful \e[0m"
    else
        echo -e "\e[1;41m Compilation Failed \e[0m"
    fi

    cd $base_dir                    # switch back to original folder

    local end_time=`date +%s`
    printtime start_time end_time
}
export -f kratoscompilation


runkratos() {
    # function to execute kratos serial (omp-parallel)
    checkforkratos

    kratosinformation
    checkbranch

    if [[ $# = 0 ]]; then
        echo "No inputfile given"
        return 1

    else
        if [[ $version == "mpi" ]]; then
            printwarning "running serial Kratos with mpi compilation!"
        fi

        echo "===== SERIAL EXECUTION ====="
        ompgetthreads
        echo ""
        sleep 2

        local start_time=`date +%s`

        python3 "$@" # passing all the arguments

        local end_time=`date +%s`
        printtime start_time end_time
    fi
}
export -f runkratos

runkratosmpi() {
    # function to execute kratos mpi-parallel
    checkforkratos

    kratosinformation
    checkbranch

    if [[ $# < 2 ]]; then
        echo "At least inputfile and number of processes have to be given"
        return 1

    else
        if [[ $version == "serial" ]]; then
            throwerror "trying to run Kratos with serial compilation in MPI!"
        fi

        if ! [[ $2 =~ ^[0-9]+$ ]] # checking if the second argument is an integer
            then
                throwerror "the second argument has to be the number of processes"
        fi

        echo "===== PARALLEL EXECUTION ====="
        echo "with $2 processes (and setting OMP_NUM_THREADS=1)"
        echo ""
        local omp_num_threads=$OMP_NUM_THREADS
        export OMP_NUM_THREADS=1
        sleep 2

        local start_time=`date +%s`

        mpiexec -np $2 python3 $1 --using-mpi "${@:3}" # passing all the arguments

        local end_time=`date +%s`
        printtime start_time end_time
        export OMP_NUM_THREADS=$omp_num_threads
     fi
}
export -f runkratosmpi


kratosinformation() {
    checkforkratos

    echo -e "Kratos Path: \t\e[1;48;5;4m ${KRATOS_PATH_ENV} \e[0m"

    if [ ! -f ${KRATOS_PATH_ENV}/.kratoscompilation.info ]; then
        throwerror "No Kratos Libraries available!"
    else
        branch="$(sed '1q;d' ${KRATOS_PATH_ENV}/.kratoscompilation.info)"
        version="$(sed '2q;d' ${KRATOS_PATH_ENV}/.kratoscompilation.info)"
        mode="$(sed '3q;d' ${KRATOS_PATH_ENV}/.kratoscompilation.info)"

        echo -e "\e[1mCompiled Configuration Information: \e[0m"
        echo -e "Branch: \t\e[1;48;5;4m $branch \e[0m"
        echo -e "Version: \t\e[1;48;5;4m $version \e[0m"
        if [[ $mode == "Debug" ]]; then
            echo -e "Mode: \t\t\e[1;48;5;37m $mode \e[0m"
        else
            echo -e "Mode: \t\t\e[1;48;5;4m $mode \e[0m"
        fi
    fi
}
export -f kratosinformation


checkbranch() {
    checkforkratos

    getactivebranch active_branch
    local compiled_branch="$(sed '1q;d' ${KRATOS_PATH_ENV}/.kratoscompilation.info)"

    if [[ $active_branch != $compiled_branch ]]; then
        echo -e "\n\t Compiled branch: $compiled_branch"
        echo -e "\t Active branch: $active_branch"
        printwarning "Compiled branch is different from active branch"
    fi
}
export -f checkbranch


getactivebranch() {
    checkforkratos

    cd ${KRATOS_PATH_ENV}
    local branch="$(git branch | grep \* | cut -d ' ' -f2)"
    cd - &> /dev/null
    local  __resultvar=$1
    eval $__resultvar="'$branch'"
}
export -f getactivebranch


printinfo() {
    local info2print="Info: "$1
    echo -e "\e[1;48;5;105m $info2print \e[0m"
}

printwarning() {
    local warning2print="Warning: "$1
    echo -e "\e[1;48;5;166m $warning2print \e[0m\n"
    sleep 2
}
export -f printwarning

throwerror() {
    local error2print="Error: "$1
    echo -e "\e[1;48;5;124m $error2print \e[0m"
    kill -INT $$
}
export -f throwerror

printtime() {
    local runtime=$(($2-$1))
    printf '\e[1mexecution time: \e[1;48;5;57m%dd %02dh : %02dm : %02ds\e[0m\n' $(($runtime/86400)) $(($runtime%86400/3600)) $(($runtime%3600/60)) $(($runtime%60))
}
export -f printtime

# runkratosvalgrind() {
# # function to execute kratos in parallel with valgrind

#     checkforkratos

#     local valgrind_options="--leak-check=full --show-leak-kinds=all --track-origins=yes"
#     eval local valgrind_out_file="valgrindout_$1.log"

#     if [[ $# = 1 ]]; then
#         echo "===== SERIAL EXECUTION ====="
#         echo "===== VALGRIND ====="
#         echo "with options: $valgrind_options"
#         echo "Valgrind output written to \"$valgrind_out_file\""
#         sleep 0.3

#         valgrind $valgrind_options python3 $1 2> $valgrind_out_file

#     elif [[ $# = 2 ]]; then
#         echo "===== PARALLEL EXECUTION ====="
#         echo "with $2 processes"
#         echo "===== VALGRIND ====="
#         echo "with options: $valgrind_options"
#         echo "Valgrind output written to \"$valgrind_out_file\""
#         sleep 0.3

#         #MPIWRAP_DEBUG=[wrapper-args]                               \
#         #LD_PRELOAD=$prefix/lib/valgrind/libmpiwrap-<platform>.so   \
#         #mpirun [mpirun-args]                                       \
#         #$prefix/bin/valgrind [valgrind-args]                       \
#         #[application] [app-args]

#         #MPIWRAP_DEBUG=[wrapper-args]                                                                                  \
#         LD_PRELOAD=/home/philippb/software/Valgrind/valgrind-3.12.0_install/lib/valgrind/libmpiwrap-amd64-linux.so    \
#         mpiexec -np $2                                                                                                \
#         /home/philippb/software/Valgrind/valgrind-3.12.0_install/bin/valgrind  $valgrind_options                      \
#         python3 $1 &> $valgrind_out_file

#     else
#         echo "Wrong number of input arguments given"
#         return 1
#     fi
# }