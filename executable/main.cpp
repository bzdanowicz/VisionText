#include <processing/ProcessingManager.h>
#include <iostream>
#include <opencv2/highgui/highgui.hpp>
#include <opencv2/imgproc/imgproc.hpp>
#include "baseapi.h"
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

struct TessOutput
{
    long words;
    std::string text;
    float confidence;
};

TessOutput recognize(cv::Mat image)
{
    tesseract::TessBaseAPI tess;
    if (tess.Init(NULL, "pol")) {
        fprintf(stderr, "Could not initialize tesseract.\n");
        exit(1);
    }

    tess.SetPageSegMode(tesseract::PageSegMode::PSM_AUTO);
    tess.SetVariable("save_best_choices", "T");


    tess.SetImage((uchar*)image.data, image.size().width, image.size().height, image.channels(), image.step1());
    tess.Recognize(0);
    auto result = tess.GetIterator();

    int words {};
    double confidence = 0;
    std::string text;
    do
    {
        std::string str = result->GetUTF8Text(tesseract::RIL_WORD);
        bool alnum = std::find_if(str.begin(), str.end(), ::isalnum) != str.end();
        text += str + " ";
        if (alnum)
        {
            ++words;
            confidence += result->Confidence(tesseract::RIL_WORD);
        }

        if (result->IsAtFinalElement(tesseract::RIL_TEXTLINE, tesseract::RIL_WORD))
        {
            text += "\n";
        }

        if (result->IsAtFinalElement(tesseract::RIL_PARA, tesseract::RIL_WORD))
        {
            text += "\n";
        }

    } while (result->Next(tesseract::RIL_WORD));
    result->Begin();

    if (words > 0)
        confidence /= words;

    TessOutput output;
    output.confidence = confidence;
    output.text = text;
    output.words = words;

    return output;
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