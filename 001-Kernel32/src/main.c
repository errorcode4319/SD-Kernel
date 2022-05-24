#include "types.h"


void PutText(int x, int y, const char* pText);


// Entry Point
void Main() {
    PutText(0, 3, "32Bit Kernel has written in C");
}

void PutText(int x, int y, const char* pText) {

    Char*   pVideoMem = (Char*)0xB800;
    int i;
    pVideoMem += (y * 80) + x;
    for(i=0; pText[i] != 0; i++) {
        pVideoMem[i].val = pText[i];
    }
}