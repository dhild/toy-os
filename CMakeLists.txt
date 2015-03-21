cmake_minimum_required(VERSION 3.2)

project(TOY_OS)
set(CMAKE_ASM_NASM_OBJECT_FORMAT elf64)
enable_language(ASM_NASM)

set(TOY_OS_VERSION_MAJOR 0)
set(TOY_OS_VERSION_MINOR 0)
set(TOY_OS_VERSION_PATCH 1)

if (NOT PACKAGE_VERSION)
  set(PACKAGE_VERSION "${TOY_OS_VERSION_MAJOR}.${TOY_OS_VERSION_MINOR}.${TOY_OS_VERSION_PATCH}")
endif()

set_property(GLOBAL PROPERTY USE_FOLDERS ON)

set(TOY_OS_MAIN_SRC_DIR     ${CMAKE_CURRENT_SOURCE_DIR}  )
set(TOY_OS_BINARY_DIR       ${CMAKE_CURRENT_BINARY_DIR}  )

set(BUILD_SHARED_LIBS OFF)

set(TOY_OS_TARGET_ARCH "x86_64"
  CACHE STRING "Set target to use for TOY_OS.")
set(TOY_OS_TARGET_TRIPLE "x86_64-pc-elf" CACHE STRING
  "Default target for which TOY_OS will generate code." )
set(CMAKE_SYSTEM_NAME Linux)
set(CMAKE_C_COMPILER "clang -v -march=x86-64")
set(CMAKE_C_COMPILER_TARGET ${TOY_OS_TARGET_TRIPLE})
set(CMAKE_CXX_COMPILER "clang++ -march=x86-64")
set(CMAKE_CXX_COMPILER_TARGET ${TOY_OS_TARGET_TRIPLE})
set(RULE_LAUNCH_LINK "lld -flavor gnu")
execute_process(COMMAND gcc ${CMAKE_C_FLAGS} ${CMAKE_LINK_FLAGS}
  -print-file-name=crtbegin.o
  OUTPUT_VARIABLE COMPILER_CRTBEGIN)
execute_process(COMMAND gcc ${CMAKE_C_FLAGS} ${CMAKE_LINK_FLAGS}
  -print-file-name=crtend.o
  OUTPUT_VARIABLE COMPILER_CRTEND)

set(TOY_OS_DISK_DIR "${TOY_OS_BINARY_DIR}/disk" CACHE STRING
   "Installation directory for the system.")
set(TOY_OS_SYSROOT_DIR "${TOY_OS_BINARY_DIR}/sysroot" CACHE STRING
   "Sysroot directory for the system.")

set(CMAKE_STAGING_PREFIX ${TOY_OS_DISK_DIR})
set(CMAKE_INSTALL_PREFIX ${TOY_OS_DISK_DIR})
set(CMAKE_SYSROOT ${TOY_OS_SYSROOT_DIR})
set(CMAKE_FIND_ROOT_PATH ${TOY_OS_DISK_DIR})
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)


option(TOY_OS_ENABLE_WARNINGS "Enable compiler warnings." ON)

option(TOY_OS_ENABLE_PEDANTIC "Compile with pedantic enabled." ON)
option(TOY_OS_ENABLE_WERROR "Fail and stop if a warning is triggered." OFF)

set(CMAKE_INCLUDE_CURRENT_DIR ON)
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -v -m64 -mcmodel=large")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -v -fno-rtti -m64 -mcmodel=large -std=c++11")

if ( TOY_OS_ENABLE_WARNINGS )
  set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -Wextra")
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wextra")
  add_compile_options(-Wall)
endif ( TOY_OS_ENABLE_WARNINGS )
if ( TOY_OS_ENABLE_PEDANTIC )
  set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -pedantic")
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -pedantic")
endif ( TOY_OS_ENABLE_PEDANTIC )
if ( TOY_OS_ENABLE_WERROR )
  add_compile_options(-Werror)
endif ( TOY_OS_ENABLE_WERROR )

include_directories("libc/include")

add_subdirectory(kernel)
add_subdirectory(libc)
