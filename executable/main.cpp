#include <processing/ProcessingManager.h>
#include <recognition/TesseractManager.h>
#include <iostream>
#include <opencv2/highgui/highgui.hpp>
#include <opencv2/imgproc/imgproc.hpp>
#include "baseapi.h"

#include <algorithm>

#include <memory>

#include <fstream>

void showImageAndWait(cv::Mat image)
{
    cv::imshow("TextVision", image);
    cv::waitKey(0);
}

void showImageAndWait(std::vector<cv::Mat> images)
{
    for (auto& image : images)
    {
        cv::imshow("TextVision", image);
        cv::waitKey(0);
    }
}

int main(int argc, char** argv)
{
    if (argc == 2)
    {
        std::string imageName = argv[1];
        std::cout << imageName;

        ProcessingManager pm;
        auto regions = pm.loadImageAndFindRegions(imageName);
        showImageAndWait(regions);       
    }

    std::string imageName("C:/Users/Bartosz/Downloads/copy/copy/skan1.png");

    ProcessingManager pm;
    TesseractManager tm("pol");

    auto imageWithRegions = pm.loadImageAndFindRegions(imageName);

    auto recognized = tm.recognize(imageWithRegions.at(0));

    std::ofstream out("C:/Users/Bartosz/Downloads/copy/copy/ocr.txt", std::ofstream::trunc);
    out << recognized;

    showImageAndWait(imageWithRegions);
    return 0;
}