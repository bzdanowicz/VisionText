#pragma once
#include <recognition/IRecognitionManager.h>
#include <memory>
#include "baseapi.h"

class TesseractManager : public IRecognitionManager
{
public:
    enum class Style
    {
        Original,
        Combined
    };

    TesseractManager(std::string language, Style style);
    std::string recognize(cv::Mat image);

private:
    std::string readText(std::shared_ptr<tesseract::ResultIterator> result) const;
    tesseract::TessBaseAPI tesseract;
    Style style;
};