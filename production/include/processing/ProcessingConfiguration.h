#pragma once

enum class ThresholdType
{
    Adaptive,
    Sauvola
};

struct ProcessingConfiguration
{
    bool shouldResize = false;
    double height = 0;
    double width = 0;

    ThresholdType thresholdType = ThresholdType::Sauvola;
    double adaptiveThresholdBlockSize = 55; 
    double adaptiveThresholdConstant = 20;
    double sharpeningAlpha = 1.5;
    double sharpeningBeta = -0.5;
    double minimumAngle = 0.5;
    double bordersOffset = 0.006;
    double minRegionHeight = 0.035;
};