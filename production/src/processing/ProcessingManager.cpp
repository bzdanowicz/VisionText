#include <processing/ProcessingHelper.h>
#include <processing/ProcessingManager.h>
#include <processing/thresholder.h>

#include <algorithm>
#include <numeric>
#include <math.h>
#include <exception>

#include <opencv2/highgui/highgui.hpp>
#include <opencv2/imgproc/imgproc.hpp>

void showImage(cv::Mat image)
{
    cvNamedWindow("TextVision", CV_WINDOW_NORMAL);
    cv::imshow("TextVision", image);
    cv::waitKey(0);
}

std::vector<cv::Mat> ProcessingManager::loadImageAndFindRegions(std::string imageName)
{
    cv::Mat image = loadImage(imageName);

    double angle = calculateSkew(image.clone());

    if (std::abs(angle) > configuration.minimumAngle)
    {
        image = deskew(image, angle);
    }

    int letterHeight = calculateHeight(image.clone());

    if (letterHeight < configuration.minimumLetterHeight || letterHeight > configuration.maximumLetterHeight)
    {
        double ratio = static_cast<double>(configuration.prefferedLetterHeight) / letterHeight;
        resize(image, image, cv::Size(), ratio, ratio);
    }

    auto processedImage = processImage(image);
    return findRegions(processedImage);
}

cv::Mat ProcessingManager::loadImage(std::string imageName)
{
    cv::Mat image = cv::imread(imageName.c_str(), cv::IMREAD_GRAYSCALE);
    if (image.empty())
    {
        throw std::exception("Could not open or find the image");
    }
    showImage(image);
    return image;
}

cv::Mat ProcessingManager::processImage(cv::Mat image)
{
    image = sharp(image);

    if (configuration.thresholdType == ThresholdType::Adaptive || image.size().height < 1000)
    {
        cv::adaptiveThreshold(image, image, 255, CV_THRESH_BINARY, CV_ADAPTIVE_THRESH_MEAN_C, configuration.adaptiveThresholdBlockSize, configuration.adaptiveThresholdConstant);
    }
    else
    {
        BhThresholder bht;
        bht.doThreshold(image, image, BhThresholdMethod::SAUVOLA);
        cv::bitwise_not(image, image);
    }
    return image;
}

double ProcessingManager::calculateSkew(cv::Mat image) const
{
    BhThresholder bht;
    bht.doThreshold(image, image, BhThresholdMethod::SAUVOLA);

    std::vector<cv::Vec4i> lines;
    cv::HoughLinesP(image, lines, 1, CV_PI / 180, 50, image.size().width / 2, image.size().height * configuration.minRegionHeight);

    if (!lines.size())
    {
        return 0;
    }

    std::vector<double> angles;
    for (auto& line : lines)
    {
        angles.push_back(atan2((double)line[3] - line[1],
            (double)line[2] - line[0]) * 180 / CV_PI);
    }

    std::sort(angles.begin(), angles.end());
    int discard = static_cast<int>(0.2 * angles.size());
    return std::accumulate(angles.begin() + discard, angles.end() - discard, 0.0) / std::distance(angles.begin() + discard, angles.end() - discard);
}

int ProcessingManager::calculateHeight(cv::Mat image) const
{
    BhThresholder bht;
    bht.doThreshold(image, image, BhThresholdMethod::SAUVOLA);

    std::vector<cv::Vec4i> lines;
    cv::HoughLinesP(image, lines, 1, CV_PI / 180, 50, image.size().width / 2, image.size().height * configuration.minRegionHeight);

    if (!lines.size())
    {
        return 0;
    }

    std::vector<int> height;
    for (size_t i = 0; i < lines.size(); i++)
    {
        cv::Vec4i l = lines[i];
        cv::line(image, cv::Point(l[0], l[1]), cv::Point(l[2], l[3]), cv::Scalar(255, 255, 255), 3, CV_AA);
    }

    cv::morphologyEx(image, image, cv::MORPH_OPEN, getStructuringElement(cv::MORPH_ELLIPSE, cv::Size(static_cast<int>(image.size().width * 0.08), 7)));
    cv::threshold(image, image, 150, 255, CV_THRESH_BINARY);

    std::vector<std::vector<cv::Point>> contours;
    std::vector<cv::Vec4i> hierarchy;
    findContours(image, contours, hierarchy, CV_RETR_TREE, CV_CHAIN_APPROX_SIMPLE, cv::Point(0, 0));

    std::vector<cv::RotatedRect> rects(contours.size());

    for (auto& contour : contours)
    {
        rects.push_back(minAreaRect(cv::Mat(contour)));
    }

    std::vector<cv::RotatedRect> filteredRects;
    std::copy_if(rects.begin(), rects.end(), std::back_inserter(filteredRects), [](cv::RotatedRect rect) {
        return rect.size.height > 3 && rect.size.height < 100;
    });

    if (filteredRects.size() == 0)
    {
        return 0;
    }

    std::nth_element(filteredRects.begin(), filteredRects.begin() + filteredRects.size() / 2, filteredRects.end(), [](cv::RotatedRect lhs, cv::RotatedRect rhs) {
        return lhs.size.height < rhs.size.height;
    });

    cv::RotatedRect median = filteredRects.at(filteredRects.size() / 2);
    return static_cast<int>(median.size.height);
}

std::vector<cv::Mat> ProcessingManager::findRegions(cv::Mat image) const
{
    auto regions = findBorders(image.clone());
    std::vector<cv::Mat> uniqueRegions;

    std::for_each(regions.begin(), regions.end(), [&uniqueRegions, &image](cv::Rect rect) {
        uniqueRegions.insert(uniqueRegions.begin(), image.clone()(rect));
    });
    showImage(uniqueRegions.at(1));
    return uniqueRegions;
}

std::vector<cv::Rect> ProcessingManager::findBorders(cv::Mat image) const
{
    cv::bitwise_not(image, image);
    std::vector<cv::Vec4i> lines;
    cv::HoughLinesP(image, lines, 1, CV_PI / 180, 10, image.size().width / 20, image.size().height * configuration.minRegionHeight);
    for (size_t i = 0; i < lines.size(); i++)
    {
        cv::Vec4i l = lines[i];
        line(image, cv::Point(l[0], l[1]), cv::Point(l[2], l[3]), cv::Scalar(255, 255, 255), 3, CV_AA);
    }
    cv::morphologyEx(image, image, cv::MORPH_CLOSE, getStructuringElement(cv::MORPH_ELLIPSE, cv::Size(1, static_cast<int>(image.size().height * configuration.minRegionHeight))));
    cv::morphologyEx(image, image, cv::MORPH_OPEN, getStructuringElement(cv::MORPH_ELLIPSE, cv::Size(static_cast<int>(image.size().width * 0.08), 5)));
    cv::threshold(image, image, 150, 255, CV_THRESH_BINARY);

    std::vector<std::vector<cv::Point>> contours;
    std::vector<cv::Vec4i> hierarchy;
    findContours(image, contours, hierarchy, CV_RETR_TREE, CV_CHAIN_APPROX_SIMPLE, cv::Point(0, 0));

    std::vector<std::vector<cv::Point>> contours_poly(contours.size());
    std::vector<cv::Rect> boundRects;

    for (size_t i = 0; i < contours.size(); i++)
    {
        cv::approxPolyDP(cv::Mat(contours[i]), contours_poly[i], 3, true);
        auto contoursMat = cv::Mat(contours_poly[i]);
        auto rect = cv::boundingRect(contoursMat);
        if (rect.size().width > image.size().width * 0.2 && rect.size().height > image.size().height * configuration.minRegionHeight)
        {
            int offset = static_cast<int>(image.size().height * configuration.bordersOffset);
            rect.y -= offset;
            rect.y = rect.y < 0 ? 0 : rect.y;
            rect.height += 2 * offset;
            rect.height = rect.y + rect.height > image.size().height ? rect.height - (rect.y + rect.height) + image.size().height : rect.height;
            boundRects.push_back(rect);
        }
    }

    auto uniqueBoundRects = helpers::removeOverlappingRectangles(boundRects);
    std::sort(uniqueBoundRects.begin(), uniqueBoundRects.end(), [](cv::Rect r1, cv::Rect r2) {
        return r1.y > r2.y;
    });

    return uniqueBoundRects;
}

cv::Mat ProcessingManager::deskew(cv::Mat image, double angle)
{
    cv::RotatedRect box = cv::RotatedRect(cv::Point2f(static_cast<float>(image.size().width / 2.0), static_cast<float>(image.size().height / 2.0)), 
        cv::Point2f(static_cast<float>(image.size().width), static_cast<float>(image.size().height)), 0);
    cv::Mat rot_mat = cv::getRotationMatrix2D(box.center, angle, 1);
    cv::warpAffine(image, image, rot_mat, image.size(), cv::INTER_CUBIC, cv::BORDER_CONSTANT, cv::Scalar(255, 255, 255));
    return image;
}

cv::Mat ProcessingManager::sharp(cv::Mat image)
{
    image.convertTo(image, CV_32F);
    cv::Mat outputImage;

    GaussianBlur(image, outputImage, cv::Size(0, 0), 3);
    addWeighted(image, configuration.sharpeningAlpha, outputImage, configuration.sharpeningBeta, 0, outputImage);

    outputImage.convertTo(outputImage, CV_8U);

    return outputImage;
}

ProcessingConfiguration ProcessingManager::getConfiguration() const
{
    return configuration;
}

void ProcessingManager::setConfiguration(const ProcessingConfiguration& conf)
{
    configuration = conf;
}