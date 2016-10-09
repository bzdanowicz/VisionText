#include <recognition/TesseractManager.h>
#include <memory>
#include <opencv2/core/core.hpp>

TesseractManager::TesseractManager(std::string language)
{
    if (tesseract.Init(nullptr, language.c_str()))
    {
        throw std::exception("Could not initialize tesseract");
    }

    tesseract.SetPageSegMode(tesseract::PageSegMode::PSM_AUTO);
    tesseract.SetVariable("save_best_choices", "T");
}

std::string TesseractManager::recognize(cv::Mat image)
{
    tesseract.SetImage((uchar*)image.data, image.size().width, image.size().height, image.channels(), image.step1());
    tesseract.Recognize(0);
    std::shared_ptr<tesseract::ResultIterator> result(tesseract.GetIterator());

    std::ostringstream recognizedText;
    do
    {
        std::string str = result->GetUTF8Text(tesseract::RIL_WORD);
       
        if (str.size() == 1 && isspace(str.c_str()[0]))
        {
            continue;
        }
        recognizedText << str;

        if (!result->IsAtFinalElement(tesseract::RIL_TEXTLINE, tesseract::RIL_WORD))
        {
            recognizedText << " ";
        }
        
        if (result->IsAtFinalElement(tesseract::RIL_TEXTLINE, tesseract::RIL_WORD))
        {
            recognizedText << std::endl;
        }

        if (result->IsAtFinalElement(tesseract::RIL_PARA, tesseract::RIL_WORD))
        {
            recognizedText << std::endl;
        }

    } while (result->Next(tesseract::RIL_WORD));

    return recognizedText.str();
}