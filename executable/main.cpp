#include <processing/ProcessingManager.h>
#include <iostream>
#include <opencv2/highgui/highgui.hpp>

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
    return 0;
}
