# Adapted from https://github.com/banach-space/clang-tutor/blob/main/CMakeLists.txt

#===============================================================================
# -1 PARSE CLANG VERSION, DIRECTORY AND INCLUDE PATHS
#===============================================================================
if (NOT CMAKE_CXX_COMPILER_ID STREQUAL Clang)
  message(FATAL_ERROR "CMAKE_CXX_COMPILER must be Clang")
endif()

set(ENV{CLANGXX} ${CMAKE_CXX_COMPILER})

execute_process(COMMAND ${CMAKE_CURRENT_LIST_DIR}/ClangVersion.sh
                RESULT_VARIABLE Clang_VERSION_ERROR
                OUTPUT_VARIABLE Clang_VERSION)

if (NOT ${Clang_VERSION_ERROR} EQUAL 0)
  message(FATAL_ERROR "Failed to determine clang directory")
endif()

execute_process(COMMAND ${CMAKE_CURRENT_LIST_DIR}/ClangDir.sh
                RESULT_VARIABLE Clang_DIR_ERROR
                OUTPUT_VARIABLE Clang_DIR)

if (NOT ${Clang_DIR_ERROR} EQUAL 0)
  message(FATAL_ERROR "Failed to determine clang directory")
endif()

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
set(CT_LLVM_INCLUDE_DIR "${CT_Clang_INSTALL_DIR}/include/llvm")
if(NOT EXISTS "${CT_LLVM_INCLUDE_DIR}")
message(FATAL_ERROR
  " CT_Clang_INSTALL_DIR (${CT_LLVM_INCLUDE_DIR}) is invalid.")
endif()

set(CT_LLVM_CMAKE_FILE
  "${CT_Clang_INSTALL_DIR}/lib/cmake/clang/ClangConfig.cmake")
if(NOT EXISTS "${CT_LLVM_CMAKE_FILE}")
message(FATAL_ERROR
  " CT_LLVM_CMAKE_FILE (${CT_LLVM_CMAKE_FILE}) is invalid.")
endif()

#===============================================================================
# 2. LOAD CLANG CONFIGURATION
#    Extracted from:
#    http://llvm.org/docs/CMake.html#embedding-llvm-in-your-project
#===============================================================================
list(APPEND CMAKE_PREFIX_PATH "${CT_Clang_INSTALL_DIR}/lib/cmake/clang/")

find_package(Clang REQUIRED CONFIG)

# Sanity check. As Clang does not expose e.g. `CLANG_VERSION_MAJOR` through
# AddClang.cmake, we have to use LLVM_VERSION_MAJOR instead.
if(NOT ${Clang_VERSION} VERSION_EQUAL "${LLVM_VERSION_MAJOR}")
  message(FATAL_ERROR "Found LLVM ${LLVM_VERSION_MAJOR}, but need LLVM 12")
endif()

message(STATUS "Found Clang ${LLVM_PACKAGE_VERSION}")
message(STATUS "Using ClangConfig.cmake in: ${CT_Clang_INSTALL_DIR}")

message("CLANG STATUS:
  Includes (clang)    ${CLANG_INCLUDE_DIRS}
  Includes (llvm)     ${LLVM_INCLUDE_DIRS}"
)
