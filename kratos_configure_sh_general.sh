#!/bin/bash
# Custom script to be used in combination with "https://github.com/philbucher/bash_scripts"

compiler="GCC"
# compiler="CLANG"
# compiler="ICC"
use_unity_build=OFF

# Function to add apps
add_app () {
    export KRATOS_APPLICATIONS="${KRATOS_APPLICATIONS}$1;"
}

# Set compiler
if [ "$compiler" = GCC ] ; then
    echo '\e[1;48;5;57m Using GCC \e[0m'
    export CC=gcc
    export CXX=g++
elif [ "$compiler" = CLANG ] ; then
    echo '\e[1;48;5;57m Using CLANG \e[0m'
    export CC=clang
    export CXX=clang++
elif [ "$compiler" = ICC ] ; then
    echo '\e[1;48;5;57m Using INTEL \e[0m'
    export CC=icc
    export CXX=icpc
else
    echo 'Unsupported compiler: $compiler'
    exit 1
fi

echo '\e[1;48;5;57m Using unity build:' $use_unity_build  '\e[0m'

# Set variables
export KRATOS_APP_DIR="${KRATOS_SOURCE}/applications"
export BOOST_ROOT="${HOME}/software/boost/boost_1_74_0"
export KRATOS_INSTALL_PYTHON_USING_LINKS=ON

# Set basic configuration
export PYTHON_EXECUTABLE=${PYTHON_EXECUTABLE:-"/usr/bin/python3"}

# Set applications to compile
export KRATOS_APPLICATIONS=${KRATOS_APPLICATIONS}$1;
add_app ${KRATOS_APP_DIR}/LinearSolversApplication
add_app ${KRATOS_APP_DIR}/StructuralMechanicsApplication
add_app ${KRATOS_APP_DIR}/ParticleMechanicsApplication
add_app ${KRATOS_APP_DIR}/FluidDynamicsApplication
add_app ${KRATOS_APP_DIR}/DEMApplication
add_app ${KRATOS_APP_DIR}/CoSimulationApplication
add_app ${KRATOS_APP_DIR}/MappingApplication
add_app ${KRATOS_APP_DIR}/MeshMovingApplication
add_app ${KRATOS_APP_DIR}/HDF5Application
# add_app ${KRATOS_APP_DIR}/MeshingApplication
# add_app ${KRATOS_APP_DIR}/ContactStructuralMechanicsApplication

# Clean
rm -rf "${KRATOS_BUILD}/cmake_install.cmake"
rm -rf "${KRATOS_BUILD}/CMakeCache.txt"
rm -rf "${KRATOS_BUILD}/CMakeFiles"

# Configure
cmake -H"${KRATOS_SOURCE}" -B"${KRATOS_BUILD}" \
${KRATOS_CMAKE_OPTIONS_FLAGS} \
-DCMAKE_UNITY_BUILD=$use_unity_build \
-DCMAKE_CXX_FLAGS="${CMAKE_CXX_FLAGS} ${KRATOS_CMAKE_CXX_FLAGS} -std=c++11 -Wall -Wno-deprecated-declarations" \
-DCMAKE_C_FLAGS="${CMAKE_C_FLAGS} -Wall" \
-DCMAKE_INSTALL_PREFIX="${KRATOS_SOURCE}/install" \
-DKRATOS_BUILD_TESTING=ON \
-DTRILINOS_INCLUDE_DIR="/usr/include/trilinos" \
-DTRILINOS_LIBRARY_DIR="/usr/lib/x86_64-linux-gnu" \
-DTRILINOS_LIBRARY_PREFIX="trilinos_" \
-DTRILINOS_EXCLUDE_ML_SOLVER=OFF \
-DTRILINOS_EXCLUDE_AMESOS_SOLVER=OFF \
-DTRILINOS_EXCLUDE_AZTEC_SOLVER=OFF \
-DUSE_EIGEN_MKL=OFF \
-DUSE_EIGEN_FEAST=OFF

# Build
cmake --build "${KRATOS_BUILD}" --target install -- -j$(nproc)


