#include "image_builder.h"




bool ImageBuilder::newImage(const std::string& targetPath) {
    mImgOut.open(
        targetPath, 
        std::ios::binary | std::ios::trunc);
    if (mImgOut.is_open()) {
        return true;
    }
}

bool ImageBuilder::saveImage() {
    bool success = updateKernelInfo();
    if (!success) 
        return false;
    mImgOut.close();
    mImageSize      = 0;
    mNumSectors     = 0;
}

int ImageBuider::addBin(const std::string& binPath) {
    std::ifstream fin(binPath);
    if (fin.fail()) {
        return -1;
    }
    fin.seekg(0, std::ios::end);
    size_t len = fin.tellg();
    fin.seekg(0, std::ios::beg);
    std::vector<uint8_t> buf(len);
    fin.read(buf.data(), len);
    fin.close();
    return addBin(buf.data(), len);
}

int ImageBuilder::addBin(const uint8_t* pBuf, size_t len) {
    mImgOut.write(pBuf, len);
    size_t numAddedSector = adjustSector(len);
    mNumSectors += size_t(numAddedSector);
    mImageSize = mNumSectors * SECTOR_SIZE;
    return int(mImageSize);
}

size_t ImageBuilder::adjustSector(size_t srcLen) {
    if (srcLen % SECTOR_SIZE == 0) 
        return srcLen / SECTOR_SIZE;    
    size_t numSector = srcLen / SECTOR_SIZE + 1;
    size_t validSizeInSector = srcLen % SECTOR_SIZE;
    size_t adjustSize = SECTOR_SIZE - validSizeInSector;
    uint8_t chSpace = 0x00;
    for(int i=0;i < adjustSize;i++) {
        mImgOut.write(chSpace, 1);
    }
    return numSector;
}

bool ImageBuilder::updateKernelInfo() {
    if (!mImgOut.is_open()) 
        return false;
    if (mImageSize < SECTOR_SIZE)
        return false;   
    uint16_t u16_num_sector = uint16_t(mNumSectors);
    mImgOut.seekg(5, std::ios::beg);
    mImgOut.write(&u16_num_sector, 2);
    return true;
}

