#pragma once
#include <string>

namespace cv
{
    class Mat;
}

class IRecognitionManager
{
public:
    virtual std::string recognize(cv::Mat image) = 0;
    virtual ~IRecognitionManager() = default;
};