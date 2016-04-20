set(KERNEL_ARCH_DIR "arch/${TOY_OS_TARGET_ARCH}/${TOY_OS_TARGET_PLATFORM}")

include_directories("include")

add_definitions(-D__is_toyos_kernel)

set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -ffreestanding -fbuiltin -mno-mmx -mno-sse -mno-sse2 -mno-sse3 -mno-3dnow")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -ffreestanding -fbuiltin -mno-mmx -mno-sse -mno-sse2 -mno-sse3 -mno-3dnow")

set(CMAKE_CXX_STANDARD_LIBRARIES "")
set(CMAKE_C_STANDARD_LIBRARIES "")

include_directories("${CMAKE_CURRENT_BINARY_DIR}/include")

add_subdirectory(${KERNEL_ARCH_DIR})
add_subdirectory(kernel)

add_custom_target(kernel.elf ALL
        "${CMAKE_CXX_COMPILER}"
        "${CMAKE_CURRENT_SOURCE_DIR}/${KERNEL_ARCH_DIR}/linker.ld.S"
        -I ${CMAKE_CURRENT_SOURCE_DIR}/include
        -o linker.ld -E -P -D__ASSEMBLY__ -DLINKERSCRIPT

        COMMAND
        "${CMAKE_LINKER}"
        -o "${CMAKE_CURRENT_BINARY_DIR}/kernel.elf"
        -T linker.ld
        -z max-page-size=0x1000
        -nostdlib
        --whole-archive "$<TARGET_FILE:archkernel>"
        --no-whole-archive "$<TARGET_FILE:mainkernel>"

        DEPENDS "${CMAKE_CURRENT_SOURCE_DIR}/${KERNEL_ARCH_DIR}/linker.ld.S" archkernel mainkernel
        )

