include_directories("${CMAKE_CURRENT_SOURCE_DIR}/../include")

add_library(mainkernel
        ../include/multiboot2.h
        main.cpp ../include/kernel/main.h
        early_video.cpp ../include/kernel/early_video.h
        multiboot_utils.cpp ../include/kernel/multiboot_utils.h
        )
