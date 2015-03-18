cmake_minimum_required(VERSION 3.2)

project(TOY_OS)

set(TOY_OS_VERSION_MAJOR 0)
set(TOY_OS_VERSION_MINOR 0)
set(TOY_OS_VERSION_PATCH 1)

if (NOT PACKAGE_VERSION)
  set(PACKAGE_VERSION "${TOY_OS_VERSION_MAJOR}.${TOY_OS_VERSION_MINOR}.${TOY_OS_VERSION_PATCH}")
endif()

set_property(GLOBAL PROPERTY USE_FOLDERS ON)

string(TOUPPER "${CMAKE_BUILD_TYPE}" uppercase_CMAKE_BUILD_TYPE)

set(TOY_OS_LIBDIR_SUFFIX "" CACHE STRING "Define suffix of library directory name (32/64)" )

# They are used as destination of target generators.
set(TOY_OS_RUNTIME_OUTPUT_INTDIR ${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_CFG_INTDIR}/bin)
set(TOY_OS_LIBRARY_OUTPUT_INTDIR ${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_CFG_INTDIR}/lib${TOY_OS_LIBDIR_SUFFIX})
if(WIN32 OR CYGWIN)
  # DLL platform -- put DLLs into bin.
  set(TOY_OS_SHLIB_OUTPUT_INTDIR ${TOY_OS_RUNTIME_OUTPUT_INTDIR})
else()
  set(TOY_OS_SHLIB_OUTPUT_INTDIR ${TOY_OS_LIBRARY_OUTPUT_INTDIR})
endif()

set(TOY_OS_TOOLS_BINARY_DIR ${TOY_OS_RUNTIME_OUTPUT_INTDIR}) # --bindir
set(TOY_OS_LIBRARY_DIR      ${TOY_OS_LIBRARY_OUTPUT_INTDIR}) # --libdir
set(TOY_OS_MAIN_SRC_DIR     ${CMAKE_CURRENT_SOURCE_DIR}  ) # --src-root
set(TOY_OS_MAIN_INCLUDE_DIR ${TOY_OS_MAIN_SRC_DIR}/include ) # --includedir
set(TOY_OS_BINARY_DIR       ${CMAKE_CURRENT_BINARY_DIR}  ) # --prefix

set(TOY_OS_INCLUDE_DIR ${CMAKE_CURRENT_BINARY_DIR}/include)

set(TOY_OS_ALL_TARGETS X86_64)

set(TOY_OS_TARGETS_TO_BUILD "all"
    CACHE STRING "Semicolon-separated list of targets to build, or \"all\".")

set(TOY_OS_EXPERIMENTAL_TARGETS_TO_BUILD ""
  CACHE STRING "Semicolon-separated list of experimental targets to build.")

option(TOY_OS_ENABLE_TIMESTAMPS "Enable embedding timestamp information in build" ON)
if(TOY_OS_ENABLE_TIMESTAMPS)
  set(ENABLE_TIMESTAMPS 1)
endif()

set(TOY_OS_TARGET_ARCH "host"
  CACHE STRING "Set target to use for TOY_OS or use \"host\" for automatic detection.")

if( TOY_OS_TARGETS_TO_BUILD STREQUAL "all" )
  set( TOY_OS_TARGETS_TO_BUILD ${TOY_OS_ALL_TARGETS} )
endif()

set(TOY_OS_TARGETS_TO_BUILD
   ${TOY_OS_TARGETS_TO_BUILD}
   ${TOY_OS_EXPERIMENTAL_TARGETS_TO_BUILD})
list(REMOVE_DUPLICATES TOY_OS_TARGETS_TO_BUILD)

option(TOY_OS_ENABLE_WARNINGS "Enable compiler warnings." ON)

option(TOY_OS_ENABLE_PEDANTIC "Compile with pedantic enabled." ON)
option(TOY_OS_ENABLE_WERROR "Fail and stop if a warning is triggered." OFF)

if( NOT uppercase_CMAKE_BUILD_TYPE STREQUAL "DEBUG" )
  option(TOY_OS_ENABLE_ASSERTIONS "Enable assertions" OFF)
else()
  option(TOY_OS_ENABLE_ASSERTIONS "Enable assertions" ON)
endif()

# Define an option controlling whether we should build for 32-bit on 64-bit
# platforms, where supported.
if( CMAKE_SIZEOF_VOID_P EQUAL 8 AND NOT WIN32 )
  # TODO: support other platforms and toolchains.
  option(TOY_OS_BUILD_32_BITS "Build 32 bits executables and libraries." OFF)
endif()

option(TOY_OS_BUILD_TESTS
  "Build TOY_OS unit tests. If OFF, just generate build targets." ON)
option(TOY_OS_INCLUDE_TESTS "Generate build targets for the TOY_OS unit tests." ON)

option (TOY_OS_BUILD_DOCS "Build the toy-os documentation." ON)
option (TOY_OS_INCLUDE_DOCS "Generate build targets for toy-os documentation." ON)
option (TOY_OS_ENABLE_DOXYGEN "Use doxygen to generate toy-os API documentation." ON)
option (TOY_OS_ENABLE_SPHINX "Use Sphinx to generate toy-os documentation." ON)

set(TOY_OS_DEFAULT_TARGET_TRIPLE "x86_64-pc-elf" CACHE STRING
  "Default target for which TOY_OS will generate code." )
set(TARGET_TRIPLE "x86_64-pc-elf")

set(CMAKE_INCLUDE_CURRENT_DIR ON)

include_directories( ${TOY_OS_INCLUDE_DIR} ${TOY_OS_MAIN_INCLUDE_DIR})

if( MINGW )
  # People report that -O3 is unreliable on MinGW. The traditional
  # build also uses -O2 for that reason:
  llvm_replace_compiler_option(CMAKE_CXX_FLAGS_RELEASE "-O3" "-O2")
endif()

add_subdirectory(kernel)
add_subdirectory(libc)

if( TOY_OS_INCLUDE_TESTS )
  add_subdirectory(test)
  add_subdirectory(unittests)
endif()

if (TOY_OS_INCLUDE_DOCS)
  add_subdirectory(docs)
endif()

if (NOT TOY_OS_INSTALL_TOOLCHAIN_ONLY)
  install(DIRECTORY include/llvm include/llvm-c
    DESTINATION include
    FILES_MATCHING
    PATTERN "*.def"
    PATTERN "*.h"
    PATTERN "*.td"
    PATTERN "*.inc"
    PATTERN "LICENSE.TXT"
    PATTERN ".svn" EXCLUDE
    )

  install(DIRECTORY ${TOY_OS_INCLUDE_DIR}/llvm
    DESTINATION include
    FILES_MATCHING
    PATTERN "*.def"
    PATTERN "*.h"
    PATTERN "*.gen"
    PATTERN "*.inc"
    # Exclude include/llvm/CMakeFiles/intrinsics_gen.dir, matched by "*.def"
    PATTERN "CMakeFiles" EXCLUDE
    PATTERN "config.h" EXCLUDE
    PATTERN ".svn" EXCLUDE
    )
endif()
