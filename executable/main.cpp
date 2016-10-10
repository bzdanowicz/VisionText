#include <processing/ProcessingManager.h>
#include <recognition/TesseractManager.h>

#include <iostream>
#include <algorithm>
#include <fstream>

int main(int argc, char** argv)
{
    if (argc >= 2)
    {
        std::string imageName = argv[1];
        std::string ocrName;
        if (argv[2] != nullptr)
        {
            ocrName = argv[2];
        }
        else
        {
            ocrName = imageName + ".txt";
        }

        ProcessingManager pm;
        TesseractManager tm("pol");

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