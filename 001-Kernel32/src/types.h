#ifndef __TYPES_H_
#define __TYPES_H_


#define     uint8_t     unsigned char 
#define     uint16_t    unsigned short 
#define     uint32_t    unsigned int   
#define     uint64_t    unsigned long 
#define     bool        unsigned char 

#define     true        1
#define     false       0
#define     nullptr     0

#pragma pack(push, 1)

typedef struct __Charactor {
    uint8_t     val;
    uint8_t     attr;
} Char;

#pragma pack(pop)

#endif  // __TYPES_H_