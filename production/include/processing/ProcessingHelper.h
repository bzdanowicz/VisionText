#pragma once
#include <iterator>

#include <opencv2/core/core.hpp>

namespace helpers
{
    bool isPointInsideRectangle(cv::Point point, cv::Rect rect)
    {
        return rect.x <= point.x && point.x <= rect.x + rect.width
            && rect.y <= point.y && point.y <= rect.y + rect.height;
    }

    bool areRectanglesOverlapping(cv::Rect rect1, cv::Rect rect2)
    {
        auto in1 = isPointInsideRectangle(cv::Point(rect1.x, rect1.y), rect2) && isPointInsideRectangle(cv::Point(rect1.x + rect1.width, rect1.y + rect1.height), rect2);
        auto in2 = isPointInsideRectangle(cv::Point(rect2.x, rect2.y), rect1) && isPointInsideRectangle(cv::Point(rect2.x + rect2.width, rect2.y + rect2.height), rect1);
        return in1 || in2;
    }

    std::vector<cv::Rect> removeOverlappingRectangles(std::vector<cv::Rect> rects)
    {
        std::sort(rects.begin(), rects.end(), [](cv::Rect rect1, cv::Rect rect2) {
            return rect1.size().area() > rect2.size().area();
        });

        std::vector<cv::Rect> uniqueRects;

        std::copy_if(rects.begin(), rects.end(), std::back_inserter(uniqueRects), [&rects](cv::Rect rectangle) {
            for (auto& rect : rects)
            {
                if (rectangle != rect && areRectanglesOverlapping(rect, rectangle))
                {
                    return false;
                }
                return true;
            }
            return false;
        });

        return uniqueRects;
    }

}