file(MAKE_DIRECTORY
        ${CMAKE_BINARY_DIR}/isodir
        ${CMAKE_BINARY_DIR}/isodir/boot
        ${CMAKE_BINARY_DIR}/isodir/boot/grub)

file(WRITE ${CMAKE_BINARY_DIR}/isodir/boot/grub/grub.cfg
"set default=\"toyos-multiboot2\"
set timeout=1

insmod efi_gop
insmod efi_uga
insmod font

if loadfont ${prefix}/fonts/unicode.pf2
then
    insmod gfxterm
    set gfxmode=auto
    set gfxpayload=keep
    terminal_output gfxterm
fi

menuentry \"toyos\" {
    multiboot /boot/kernel.bin
}
menuentry \"toyos-multiboot2\" {
    multiboot2 /boot/kernel.bin
}
"
)

find_program(MAKE_RESCUE grub-mkrescue REQUIRED)

add_custom_target(
        iso
        COMMAND cp ${CMAKE_BINARY_DIR}/kernel/kernel.elf ${CMAKE_BINARY_DIR}/isodir/boot/kernel.bin
        DEPENDS kernel/kernel.elf
)

add_custom_command(
        COMMAND ${MAKE_RESCUE}
        ARGS -o ${CMAKE_BINARY_DIR}/kernel.iso ${CMAKE_BINARY_DIR}/isodir
        TARGET iso
)

if(EXISTS ${CMAKE_BINARY_DIR}/OVMF.fd)
    message(STATUS "Using cached version of UEFI boot image")
else()
    file(
            DOWNLOAD "http://downloads.sourceforge.net/project/edk2/OVMF/OVMF-X64-r15214.zip"
            ${CMAKE_BINARY_DIR}/ovmf.zip
            EXPECTED_MD5 e83e00f9348f6b004bab7f4489653147
    )
endif()

add_custom_target(
        ovmf
        COMMAND unzip -f ${CMAKE_BINARY_DIR}/ovmf.zip OVMF.fd
        WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
)

find_program(QEMU qemu-system-x86_64 REQUIRED)

add_custom_target(
        qemu
        COMMAND ${QEMU} -s -bios ${CMAKE_BINARY_DIR}/OVMF.fd -m 2048 -cdrom ${CMAKE_BINARY_DIR}/kernel.iso
        DEPENDS iso ovmf
)
