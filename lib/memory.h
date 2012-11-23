#ifndef MEMORY_H
#define MEMORY_H

#define BUDDY_PAGE_SIZE(order) ((1 << (order)) * 4 * 1024)
/* There are X levels of allocation, each twice as big as the last */
#define BUDDY_MAX_ORDER 8
#define BUDDY_MAX_PAGE_SIZE BUDDY_PAGE_SIZE(BUDDY_MAX_ORDER - 1)

#ifdef __cplusplus
extern "C" {
#endif

  void initialize(void* mem, size_t size);

#ifdef __cplusplus
}
#endif

#endif /* MEMORY_H */
