CMAKE_MINIMUM_REQUIRED(VERSION 2.8.1)
CMAKE_POLICY(VERSION 2.8.1)

SET(PROJECT_NAME processing)

PROJECT(${PROJECT_NAME})

SET(PROJECT_DIR ${PRODUCTION_DIR}/src/${PROJECT_NAME})

FILE (GLOB HEADERS ${PRODUCTION_INCLUDE_DIR}/${PROJECT_NAME}/*.h)
FILE (GLOB SOURCES ${PROJECT_DIR}/*.cpp)

ADD_LIBRARY(${PROJECT_NAME} ${SOURCES} ${HEADERS})
