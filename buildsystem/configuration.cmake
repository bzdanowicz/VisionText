SET(PROJECT_NAME "TestView" CACHE STRING "Name that will be used for executable")

SET(USE_BOOST OFF CACHE BOOL "Use Boost for this project")
IF(${USE_BOOST})
    SET(Boost_VERSION "1.55.0" CACHE STRING "Required version of Boost to use")
	SET(Boost_REQUIRED_LIBRARIES program_options CACHE LIST "Used Boost libraries")
    SET(Boost_USE_STATIC_LIBS ON CACHE BOOL "Use Boost static libraries?")
    SET(Boost_USE_STATIC_RUNTIME OFF CACHE BOOL "Use Boost static runtime libraries?")
    SET(Boost_USE_MULTITHREADED ON CACHE BOOL "Use multithreaded version of Boost libraries?")
ENDIF(${USE_BOOST})

SET(USE_OPENCV ON CACHE BOOL "Use OpenCV for the project")

SET(USE_TESSERACT ON CACHE BOOL "Use Tesseract for the project")

SET(USE_LEPTONICA ON CACHE BOOL "Use Leptonica for the project")

SET(USE_MULTITHREADING ON CACHE BOOL "Use multithreading for the project")

SET(WITH_EXECUTABLE ON CACHE BOOL "Compile executable version of the project")
SET(WITH_TESTCASES OFF CACHE BOOL "Compile test suite for the project")
SET(WITH_BENCHMARKS OFF CACHE BOOL "Compile benchmarks for the project")

IF (CMAKE_CXX_COMPILER_ID STREQUAL "GNU" OR CMAKE_CXX_COMPILER_ID STREQUAL "Clang")		
	SET(USE_ADDRESS_SANITIZER ON CACHE BOOL "Use Address Sanitizer for the build")
    SET(USE_MEMORY_SANITIZER OFF CACHE BOOL "Use Memory Sanitizer for the build")
    SET(USE_THREAD_SANITIZER OFF CACHE BOOL "Use Thread Sanitizer for the build")
    SET(USE_UNDEFINED_BEHAVIOR_SANITIZER ON CACHE BOOL "Use Undefined Behavior Sanitizer for the build")
ENDIF (CMAKE_CXX_COMPILER_ID STREQUAL "GNU" OR CMAKE_CXX_COMPILER_ID STREQUAL "Clang")

IF(CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
    SET(USE_LIBCXX ON CACHE BOOL "Use libc++ instead of libstdc++")
ENDIF(CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
