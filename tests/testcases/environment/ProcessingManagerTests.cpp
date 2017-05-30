#include "gtest/gtest.h"
#include "processing/ProcessingManager.h"

class ProcessingManagerFixture : public ProcessingManager, public ::testing::Test
{
};

TEST_F(ProcessingManagerFixture, EvironmentBasicTest)
{
    loadImage(TEST_RESOURCES + std::string("invocation_pl.png"));
}