#include <recognition/TesseractManager.h>
#include <opencv2/core/core.hpp>

TesseractManager::TesseractManager(std::string language, Style style) : style(style)
{
    if (tesseract.Init(LANGUAGE_DIR, language.c_str()))
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

    return readText(result);
}

std::string TesseractManager::readText(std::shared_ptr<tesseract::ResultIterator> result) const
{
    std::ostringstream recognizedText;
    do
    {

        std::string str = result->GetUTF8Text(tesseract::RIL_WORD);

        if (str.size() == 1 && isspace(str.c_str()[0]))
        {
            continue;
        }
        if (style == Style::Original)
        {
            recognizedText << str;
        }
        else
        {
            if (*str.rbegin() == '-'  && result->IsAtFinalElement(tesseract::RIL_TEXTLINE, tesseract::RIL_WORD))
            {
                recognizedText << std::string(str.begin(), std::next(str.end(), -1));
            }
            else
            {
                recognizedText << str;
            }
        }

        if (!result->IsAtFinalElement(tesseract::RIL_TEXTLINE, tesseract::RIL_WORD))
        {
            recognizedText << " ";
        }

        if (result->IsAtFinalElement(tesseract::RIL_TEXTLINE, tesseract::RIL_WORD) && !(*str.rbegin() == '-') && (style == Style::Combined))
        {
            recognizedText << " ";
        }

        if (style == Style::Original)
        {
            if (result->IsAtFinalElement(tesseract::RIL_TEXTLINE, tesseract::RIL_WORD))
            {
                recognizedText << std::endl;
            }
        }


        if (result->IsAtFinalElement(tesseract::RIL_PARA, tesseract::RIL_WORD))
        {
            recognizedText << std::endl;
        }
        

    } while (result->Next(tesseract::RIL_WORD));

    return recognizedText.str();
}