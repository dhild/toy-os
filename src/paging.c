#include "paging.h"

byte paging_setup_complete = 0;



void paging_setup( qword memSize ) {
    paging_setup_complete = 1;
}
