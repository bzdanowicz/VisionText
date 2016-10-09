#pragma once
#include <recognition/IRecognitionManager.h>
#include "baseapi.h"

class TesseractManager : public IRecognitionManager
{
public:
    TesseractManager(std::string language);
    std::string recognize(cv::Mat image);

private:
    std::string readText(tesseract::ResultIterator result);
    tesseract::TessBaseAPI tesseract;
};