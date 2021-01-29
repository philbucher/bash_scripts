#!/bin/bash
# Custom script to be used in combination with "https://github.com/philbucher/bash_scripts"

use_clang=OFF
use_cotire=OFF

# Function to add apps
add_app () {
    export KRATOS_APPLICATIONS="${KRATOS_APPLICATIONS}$1;"
}

# Set compiler
if [ "$use_clang" = ON ] ; then
    echo 'Using CLANG'
    export CC=clang
    export CXX=clang++
else
    echo 'Using GCC'
    export CC=gcc
    export CXX=g++
fi

# Set variables
export KRATOS_APP_DIR="${KRATOS_SOURCE}/applications"
export BOOST_ROOT="${HOME}/software/boost/boost_1_73_0"
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
-DUSE_COTIRE=$use_cotire \
-DCMAKE_CXX_FLAGS="${CMAKE_CXX_FLAGS} ${KRATOS_CMAKE_CXX_FLAGS} -std=c++11 -Wall -Wno-deprecated-declarations" \
-DCMAKE_C_FLAGS="${CMAKE_C_FLAGS} -Wall" \
-DCMAKE_INSTALL_PREFIX="${KRATOS_SOURCE}/install" \
-DKRATOS_BUILD_TESTING=ON \
-DSTRUCTURAL_DISABLE_ADVANCED_CONSTITUTIVE_LAWS=OFF \
-DTRILINOS_INCLUDE_DIR="/usr/include/trilinos" \
-DTRILINOS_LIBRARY_DIR="/usr/lib/x86_64-linux-gnu" \
-DTRILINOS_LIBRARY_PREFIX="trilinos_" \
-DTRILINOS_EXCLUDE_ML_SOLVER=OFF \
-DTRILINOS_EXCLUDE_AMESOS_SOLVER=OFF \
-DTRILINOS_EXCLUDE_AZTEC_SOLVER=OFF \
-DUSE_EIGEN_MKL=OFF \
-DUSE_EIGEN_FEAST=OFF 

# Build
if [ "$use_cotire" = ON ] ; then
    echo 'Using Cotire'
    cmake --build "${KRATOS_BUILD}" --target all_unity    -- -j$(nproc) &&\
    cmake --build "${KRATOS_BUILD}" --target install/fast -- -j$(nproc)
else
    echo 'Not using Cotire'
    cmake --build "${KRATOS_BUILD}" --target install -- -j$(nproc)
fi


