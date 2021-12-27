# Adapted from https://github.com/banach-space/clang-tutor/blob/main/CMakeLists.txt

#===============================================================================
# -1 PARSE CLANG VERSION, DIRECTORY AND INCLUDE PATHS
#===============================================================================
if (NOT CMAKE_CXX_COMPILER_ID STREQUAL Clang)
  message(FATAL_ERROR "CMAKE_CXX_COMPILER must be Clang")
endif()

set(ENV{CLANGXX} ${CMAKE_CXX_COMPILER})

# Get Clang version.
set(Clang_VERSION ${CMAKE_CXX_COMPILER_VERSION})

string(REPLACE "." ";" Clang_VERSION_LIST ${Clang_VERSION})
list(GET Clang_VERSION_LIST 0 Clang_VERSION_MAJOR)
list(GET Clang_VERSION_LIST 1 Clang_VERSION_MINOR)
list(GET Clang_VERSION_LIST 2 Clang_VERSION_PATCH)

# Get Clang directory.
execute_process(COMMAND ${CMAKE_CURRENT_LIST_DIR}/ClangDir.sh
                RESULT_VARIABLE Clang_DIR_ERROR
                OUTPUT_VARIABLE Clang_DIR)

if (NOT ${Clang_DIR_ERROR} EQUAL 0)
  message(FATAL_ERROR "Failed to determine clang directory")
endif()

set(Clang_DIR "${Clang_DIR}/${Clang_VERSION}")

# Get Clang include paths.
execute_process(COMMAND ${CMAKE_CURRENT_LIST_DIR}/ClangIncludePaths.sh
                RESULT_VARIABLE Clang_INCLUDE_PATHS_ERROR
                OUTPUT_VARIABLE Clang_INCLUDE_PATHS)

if (NOT ${Clang_INCLUDE_PATHS_ERROR} EQUAL 0)
  message(FATAL_ERROR "Failed to determine clang default include paths")
endif()

#===============================================================================
# 0. GET CLANG INSTALLATION DIR
#===============================================================================
# In clang-tutor, `CT_Clang_INSTALL_DIR` is the key CMake variable - it points
# to a Clang installation directory. For the sake of completeness,
# <PackageName>_DIR (i.e. `Clang_DIR`) and <PackageName>_ROOT (i.e.
# `Clang_ROOT`) are also supported. Visit CMake documentation for more details:
#   https://cmake.org/cmake/help/latest/command/find_package.html
# Use only _one_ of these variables.

set(CT_CLANG_PACKAGE_DIR "${Clang_DIR}/../../..")
mark_as_advanced(CT_CLANG_PACKAGE_DIR)

# Set this to a valid Clang installation directory. This is most likely where
# LLVM is installed on your system.
set(CT_Clang_INSTALL_DIR "${CT_CLANG_PACKAGE_DIR}" CACHE PATH
  "Clang installation directory")

#===============================================================================
# 1. VERIFY CLANG INSTALLATION DIR
#===============================================================================
set(CT_LLVM_INCLUDE_DIR "${CT_Clang_INSTALL_DIR}/include/llvm-${Clang_VERSION_MAJOR}")
if(NOT EXISTS "${CT_LLVM_INCLUDE_DIR}")
message(FATAL_ERROR
  " CT_Clang_INSTALL_DIR (${CT_LLVM_INCLUDE_DIR}) is invalid.")
endif()

set(CT_LLVM_CMAKE_FILE "${CT_Clang_INSTALL_DIR}/lib/cmake/clang-${Clang_VERSION_MAJOR}/ClangConfig.cmake")
if(NOT EXISTS "${CT_LLVM_CMAKE_FILE}")
message(FATAL_ERROR
  " CT_LLVM_CMAKE_FILE (${CT_LLVM_CMAKE_FILE}) is invalid.")
endif()

#===============================================================================
# 2. LOAD CLANG CONFIGURATION
#    Extracted from:
#    http://llvm.org/docs/CMake.html#embedding-llvm-in-your-project
#===============================================================================
list(APPEND CMAKE_PREFIX_PATH "${CT_Clang_INSTALL_DIR}/lib/cmake-${Clang_VERSION_MAJOR}/clang/")

find_package(Clang REQUIRED CONFIG)

message(STATUS "Found Clang ${LLVM_PACKAGE_VERSION}")
message(STATUS "Using ClangConfig.cmake in: ${CT_Clang_INSTALL_DIR}")

message("CLANG STATUS:
  Includes (clang)    ${CLANG_INCLUDE_DIRS}
  Includes (llvm)     ${LLVM_INCLUDE_DIRS}"
)
