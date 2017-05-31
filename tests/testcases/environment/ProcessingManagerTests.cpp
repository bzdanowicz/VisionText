#include "gtest/gtest.h"
#include "processing/ProcessingManager.h"

class ProcessingManagerFixture : public ProcessingManager, public ::testing::Test
{
};

TEST_F(ProcessingManagerFixture, LoadingImageShallThrowWhenFileNotExist)
{
    std::string nonExistingImage = "nonExistingImage.png";
    ASSERT_ANY_THROW(loadImage(nonExistingImage));
}

TEST_F(ProcessingManagerFixture, EmptyWhiteImageHeightAndSkewValuesShouldBeZero)
{
    auto testImage = loadImage(TEST_RESOURCES + std::string("empty_white.png"));
    ASSERT_EQ(calculateSkew(testImage), 0); 
    ASSERT_EQ(calculateHeight(testImage), 0);  
}

TEST_F(ProcessingManagerFixture, CalculatedSkewValueAfterDeskewingByValueShouldBeEqual)
{
    int inputSkewValue = 5;
    auto testImage = loadImage(TEST_RESOURCES + std::string("invocation_pl.png"));
    auto skewImage = deskew(testImage, inputSkewValue);

    double skewValue = calculateSkew(skewImage);
    ASSERT_NEAR(skewValue, -inputSkewValue, 0.3);
}

TEST_F(ProcessingManagerFixture, ImageWithTwoStanzasShouldHaveTwoRegions)
{
    auto testImage = TEST_RESOURCES + std::string("invocation_pl.png");
    auto regions = loadImageAndFindRegions(testImage);
    ASSERT_EQ(regions.size(), 2);
}

