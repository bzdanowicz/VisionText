#pragma once
#include <processing/ProcessingConfiguration.h>
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
    
    ProcessingConfiguration getConfiguration();
    void setConfiguration(ProcessingConfiguration conf);

private:
    ProcessingConfiguration configuration;
    double calculateSkew(cv::Mat image);
    cv::Mat deskew(cv::Mat image, double angle);
    cv::Mat sharp(cv::Mat image);
};