#pragma once
#include <processing/ProcessingConfiguration.h>
#include <vector>
#include <opencv2/core/core.hpp>


class ProcessingManager
{
public:
    ProcessingManager() = default;
    
    std::vector<cv::Mat> loadImageAndFindRegions(std::string imageName);
    
    ProcessingConfiguration getConfiguration() const;
    void setConfiguration(const ProcessingConfiguration& conf);

protected:
    cv::Mat loadImage(std::string imageName);
    cv::Mat processImage(cv::Mat image);

    cv::Mat deskew(cv::Mat image, double angle);
    cv::Mat sharp(cv::Mat image);

    std::vector<cv::Rect> findBorders(cv::Mat image) const;
    std::vector<cv::Mat> findRegions(cv::Mat image) const;

    double calculateSkew(cv::Mat image) const;
    int calculateHeight(cv::Mat image) const;
    
private:
    ProcessingConfiguration configuration;
};