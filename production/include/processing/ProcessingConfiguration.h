#pragma once

enum class ThresholdType
{
    Adaptive,
    Sauvola
};

struct ProcessingConfiguration
{
    ThresholdType thresholdType = ThresholdType::Sauvola;
    int adaptiveThresholdBlockSize = 55; 
    double adaptiveThresholdConstant = 20;
    double sharpeningAlpha = 1.5;
    double sharpeningBeta = -0.5;
    double minimumAngle = 0.5;
    int minimumLetterHeight = 20;
    int maximumLetterHeight = 50;
    int prefferedLetterHeight = 30;
    double bordersOffset = 0.006;
    double minRegionHeight = 0.035;
};