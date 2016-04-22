#ifndef TOY_OS_PAGING_HPP
#define TOY_OS_PAGING_HPP

#include <kernel/config.hpp>
#include <multiboot2.h>

namespace kernel
{
    class FrameAllocator {
    private:
        FrameAllocator();
        FrameAllocator(const FrameAllocator&) = delete;
        FrameAllocator(FrameAllocator&&) = delete;

        void* nextFreeFrame;
        uint64_t framesLeftInBlock;

        struct MemoryBlock {
            void* address;
            uint64_t size_in_frames;
        };

        MemoryBlock* memoryBlocks;
        uint64_t memoryBlocksCount;
        uint64_t nextFreeIndex;

    public:
        static const uint64_t FRAME_SIZE = 4096;
        static FrameAllocator& get_instance();

        void* allocate_frame();
        void deallocate_frame(void* frame);
    };

    class PagingHandler {
    public:
        static PagingHandler& get_instance();

    };
} // namespace kernel

#endif //TOY_OS_PAGING_HPP
