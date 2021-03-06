CMAKE_MINIMUM_REQUIRED(VERSION 2.8.1)
CMAKE_POLICY(VERSION 2.8.1)

SET(PROJECT_NAME VisionTextTests)

PROJECT(${PROJECT_NAME})

SET(TEST_DIR ${ROOT_DIR}/tests)
SET(TEST_FRAMEWORK_INCLUDE_DIRS ${TEST_DIR})

MESSAGE(STATUS "Using common test files from: " ${TEST_DIR})

IF(${WITH_TESTCASES})
    ADD_DEPENDENCY_TO_GTEST()
   
    ADD_DEFINITIONS(-DTEST_RESOURCES="${CMAKE_SOURCE_DIR}/tests/resources/")
	ADD_SUBDIRECTORY(testcases)
    ADD_DEPENDENCIES(${TESTCASES_PROJECT} ${INTERNAL_LIBRARIES} ${SEMI_INTERNAL_LIBRARIES} ${TEST_LIBRARIES})
	SET(TESTCASES_PROJECT ${TESTCASES_PROJECT} PARENT_SCOPE)
    
ENDIF(${WITH_TESTCASES})

IF(${WITH_BENCHMARKS})
	ADD_SUBDIRECTORY(benchmarks)
    ADD_DEPENDENCIES(${BENCHMARK_PROJECT} ${INTERNAL_LIBRARIES} ${SEMI_INTERNAL_LIBRARIES} ${TEST_LIBRARIES} ${BENCHMARK_LIBRARIES})
	SET(BENCHMARK_PROJECT ${BENCHMARK_PROJECT} PARENT_SCOPE)
ENDIF(${WITH_BENCHMARKS})
