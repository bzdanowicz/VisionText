CMAKE_MINIMUM_REQUIRED(VERSION 2.8.1)
CMAKE_POLICY(VERSION 2.8.1)

SET(EXECUTABLE_PROJECT ${PROJECT_NAME} PARENT_SCOPE)
PROJECT(${PROJECT_NAME})

INCLUDE_DIRECTORIES(${Tesseract_INCLUDE_DIRS})

SET(PROJECT_DIR ${ROOT_DIR}/executable)
FILE (GLOB SOURCES ${PROJECT_DIR}/*.cpp)

LIST(REMOVE_DUPLICATES EXTERNAL_LIBRARIES)
LIST(REMOVE_DUPLICATES INTERNAL_LIBRARIES)

ADD_EXECUTABLE(${PROJECT_NAME} ${SOURCES} ${HEADERS})
TARGET_LINK_LIBRARIES(${PROJECT_NAME} ${INTERNAL_LIBRARIES} ${SEMI_INTERNAL_LIBRARIES} ${EXTERNAL_LIBRARIES})
