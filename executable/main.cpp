#include <processing/ProcessingManager.h>
#include <recognition/TesseractManager.h>

#include <iostream>
#include <algorithm>
#include <fstream>
#include <iterator>

#include <opencv2/imgproc/imgproc.hpp>

int main(int argc, char** argv)
{
    TesseractManager tm("pol", TesseractManager::Style::Combined);
    ProcessingManager pm;

    if (argc == 2)
    {
        std::string imageName = argv[1];
        std::string ocrName = argv[2];

        auto regions = pm.loadImageAndFindRegions(imageName);

        std::string recognized;
        
        for (auto& region : regions)
        {
            recognized += tm.recognize(region);
        }
        
        std::ofstream out(ocrName, std::ofstream::trunc);
        out << recognized;

    }
    else
    {
        std::cout << "Invalid input. Please provide file name and output file path." << std::endl;
    }

    return 0;
}