#include "memalloc.h"
#include "types.h"

// These two should match!
#define ALLOCATION_ALIGNMENT 0xFFFFFFFFFFFFFFF8
#define MIN_FREE_BLOCK_SIZE 8

typedef struct {
    void* address; // Address of the free area.
    qword size;
    void* previous;
    void* next;
    void* allocated; // Not entirely sure how to use this.... Should probably
                     // eventually point to a structure indicating the caller's
                     // process information.
} header;

header* first;
header* last;

byte memory_setup_complete = 0;

void compactize();
header* setup_block( void* start, qword length );

void setup_memory( void* start, qword length ) {
    first = setup_block( start, length );
    last = first;

    memory_setup_complete = 1;
}

header* setup_block( void* start, qword length ) {
    header* temp = (header*) start;
    temp->address = start + sizeof(header);
    temp->size = length - sizeof(header);
    temp->previous = start;
    temp->next = start;
    temp->allocated = (void*) 0;
    return temp;
}

/** Finds a block with at least length bytes free.
 */
header* find_free( qword length ) {
    header* temp = first;

    while ( temp->size < length ) {
        if ( temp == last ) {
            compactize();
            temp = first;
            if ( temp->size >= length )
                break;
        }
        temp = temp->next;
    }
    
    return temp;
}

/** Compacts all the free headers together.
 */
void compactize() {
    header* temp = first;

    while ( temp != last ) {
        if ( !(temp->allocated) ) {
            header* temp2 = temp->next;
            if ( temp2 != temp && !(temp2->allocated) ) {
                temp->next = temp2->next;
                temp->size += temp2->size + sizeof(header);
            }
        } else
            temp = temp->next;
    }
}

/** Attempts to allocate a free memory block of length bytes.
 */
void* allocate( qword length ) {
    if ( !memory_setup_complete ) {
        return NULL;
    }

    // Adjust the length....
    length = (length + MIN_FREE_BLOCK_SIZE) & ALLOCATION_ALIGNMENT;

    header* target = find_free( length );

    if ( target->size > (length + sizeof(header) + MIN_FREE_BLOCK_SIZE) ) {
        // Only part of this area will be allocated. Give the rest it's
        // own free block.
        header* previous = target->previous;
        header* next2 = target->next;
        header* next = setup_block( target->address + length );

        next->previous = previous;
        next->next = next2;

        previous->next = next;
        next2->previous = next;
    }

    target->allocated = 1;

    return target->address;
}

void free( void* mem ) {
    // Need to figure out a better allocation scheme.....
    // Simply using the old pointers is insecure!
}
