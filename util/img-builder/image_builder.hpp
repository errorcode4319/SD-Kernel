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

    // Return Added Sector Count
    // Add Sector From Binary 
    size_t  addBin(const std::string& binPath);
    size_t  addBin(const uint8_t* pBuf, size_t len);

private:
    // Return Total ImageSize
    size_t  copyBin(const uint8_t* pBuf, size_t len);
    // Return Total Number of Sector
    size_t  adjustSector(size_t srcSize);

    // in saveImage()
    bool    updateKernelInfo()

private:
    size_t          mImageSize;
    size_t          mNumSectors;
    bool            mIsWorking;
    std::ofstream   mDstFileStream;
}

#endif __IMAGE_BUILDER_