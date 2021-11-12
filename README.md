Bash scripts for consistent & convenient use of Kratos and other software across systems.

In order to use the files, they only need to be executed. The recommended and consistent way to do so is to add it to `~/.bashrc` or `~/.bash_aliases` like this:
`. ~/bash_scripts/bash_kratos.sh`

The following files are provided:
- `bash_aliases_common.sh` : Contains useful aliases, e.g.:
    - `ll`: display the file sizes in readable format
    - `sort_size`: display files and folders ordered by size in the current directory
- `bash_software.sh` : Contains useful functionalities related to software (e.g. valgrind, OpenMP, gdb)
- `bash_kratos.sh` : Functions for interacting with Kratos
    - the functionalites provided here work in combination with `kratos_configure_sh_general.sh` which should be placed in the root directory of Kratos
    - add the following lines to `.git/info/exclude` to exclue them from the version control:
        ```
        cmake_build*
        install*
        kratos_configure_sh_general.sh
        .kratoscompilation.info
        .vscode/*
        ```
    - add an `alias` to start Kratos either to `~/.bashrc` or `~/.bash_aliases` to set the Kratos enironment when opening a new terminal. E.g.:
        `alias startkratosmaster="setupkratosenv ~/software/Kratos_master"`

    - Commands for _compiling_ Kratos:
        - `compilekratos`: compiles Kratos in serial (shared memory parallel) in `Release`
        - `compilekratosmpi`: compiles Kratos with MPI support in `Release`
        - `compilekratosfulldebug`: compiles Kratos in serial (shared memory parallel) in `FullDebug`
        - `compilekratosmpifulldebug`: compiles Kratos with MPI support in `FullDebug`

    - Commands for _running_ Kratos:
        - `runkratos`: runs serial (shared memory parallel) Kratos given the input file, e.g.:
        `runkratos MainKratos.py`
            - Note that additional arguments are passed to the script and can e.g. be used with pythons `sys.argv` (e.g. `runkratos MainKratos.py arg1 argt33`)
        - `runkratosmpi`: runs Kratos in MPI Kratos given the input file and the number of processors to use, e.g.:
        `runkratosmpi MainKratos.py 4`
            - Note that additional arguments are passed same as explained for `runkratos`
            - Important when using OpenMPI: Since OpenMPI version 3, it is by default not possible to use more processes than the number of theads ([reference](https://github.com/FluidityProject/fluidity/issues/182)). To overcome this, use the `OMPI_MCA_rmaps_base_oversubscribe` environment variable like in the following:
            `export OMPI_MCA_rmaps_base_oversubscribe=1 # Allow oversubscription for MPI (needed for OpenMPI >= 3.0)`

Other helpful commands:
- silence output from programs run in terminal: e.g.: `alias virtualbox='virtualbox &> /dev/null'`
- piping all output to file: `runkratos MainKraots.py |& tee kratos.log`. Note that this might introduce some delayed writing due to buffering.
