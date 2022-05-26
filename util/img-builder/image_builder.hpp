#ifndef __IMAGE_BUILDER_
#define __IMAGE_BUILDER_ 

#include <iostream>
#include <fstream>
#include <cstdint>
#include <vector>

const size_t SECTOR_SIZE = 512;

class ImageBuilder {

public:
    // Create, Close Image File 
    bool    newImage(const std::string& targetPath);
    bool    saveImage();

    // Return Total Image Size
    // If Add Bin Failed => return -1 
    int     addBin(const std::string& binPath);
    int     addBin(const uint8_t* pBuf, size_t len);

private:
    // Return Total Number of Sector
    size_t  adjustSector(size_t srcLen);

    // in saveImage()
    bool    updateKernelInfo()

private:
    size_t          mImageSize      = 0;
    size_t          mNumSectors     = 0;
    std::ofstream   mImgOut;
}

#endif __IMAGE_BUILDER_