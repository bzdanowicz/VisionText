#pragma once
#include <vector>

#include <opencv2/core/core.hpp>

class ProcessingManager
{
public:
    ProcessingManager() {};
    cv::Mat loadImage(std::string imageName);
    cv::Mat processImage(cv::Mat image);
    std::vector<cv::Rect> findBorders(cv::Mat image);
    std::vector<cv::Mat> findRegions(cv::Mat image);
    std::vector<cv::Mat> loadImageAndFindRegions(std::string imageName);

private:
    double calculateSkew(cv::Mat image);
    cv::Mat deskew(cv::Mat image, double angle);

    //Deprecated, testing purpose
public:
    cv::Mat ProcessingManager::drawRegionsOnImage(cv::Mat image);

};