SET(CMAKE_MODULE_PATH ${BUILDSYSTEM_DIR})

FUNCTION(ADD_DEPENDENCY_TO_BOOST VERSION)
    SET(REQUIRED_LIBRARIES ${ARGN})
    IF(CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
        SET_CLANG_BOOST_COMPILER_FLAGS()
    ENDIF(CMAKE_CXX_COMPILER_ID STREQUAL "Clang")

    FIND_PACKAGE(Boost ${VERSION} REQUIRED COMPONENTS ${REQUIRED_LIBRARIES})
    IF(NOT ${Boost_FOUND})
        MESSAGE(FATAL_ERROR "Unable to find the requested Boost libraries.")
    ENDIF(NOT ${Boost_FOUND})
    
    IF(NOT ("${Boost_MAJOR_VERSION}.${Boost_MINOR_VERSION}.${Boost_SUBMINOR_VERSION}" STREQUAL ${VERSION}))
        MESSAGE(WARNING "Using Boost ${Boost_MAJOR_VERSION}.${Boost_MINOR_VERSION}.${Boost_SUBMINOR_VERSION} - application is not tested with ${VERSION}, so keep cautious!")
    ENDIF(NOT ("${Boost_MAJOR_VERSION}.${Boost_MINOR_VERSION}.${Boost_SUBMINOR_VERSION}" STREQUAL ${VERSION}))

    MESSAGE(STATUS "Using Boost version: ${Boost_MAJOR_VERSION}.${Boost_MINOR_VERSION}.${Boost_SUBMINOR_VERSION}")
    MESSAGE(STATUS "Using Boost libraries: ${Boost_LIBRARIES}")
    MESSAGE(STATUS "Using Boost libraries from: ${Boost_LIBRARY_DIRS}")
    MESSAGE(STATUS "Using Boost headers from: ${Boost_INCLUDE_DIRS}")
	
	SET(Boost_LIBRARIES ${Boost_LIBRARIES} PARENT_SCOPE)
	SET(Boost_LIBRARY_DIRS ${Boost_LIBRARY_DIRS} PARENT_SCOPE)
	SET(Boost_INCLUDE_DIRS ${Boost_INCLUDE_DIRS} PARENT_SCOPE)
    
	LINK_DIRECTORIES(${Boost_LIBRARY_DIRS})
ENDFUNCTION(ADD_DEPENDENCY_TO_BOOST VERSION LIBRARIES)

FUNCTION(ADD_DEPENDENCY_TO_OPEN_CV)
    FIND_PACKAGE(OpenCV REQUIRED)
    IF(NOT ${OpenCV_FOUND})
        MESSAGE(FATAL_ERROR "Unable to find the requested OpenCV libraries.")
    ENDIF(NOT ${OpenCV_FOUND})
    
	MESSAGE(STATUS "Using OpenCV version: ${OpenCV_VERSION}")
    MESSAGE(STATUS "Using OpenCV libraries: ${OpenCV_LIBS}")
    MESSAGE(STATUS "Using OpenCV libraries from: ${OpenCV_LIB_DIR}")
    MESSAGE(STATUS "Using OpenCV headers from: ${OpenCV_INCLUDE_DIRS}")
	
	SET(OpenCV_LIBS ${OpenCV_LIBS} PARENT_SCOPE)
	SET(OpenCV_LIB_DIR ${OpenCV_LIB_DIR} PARENT_SCOPE)
	SET(OpenCV_INCLUDE_DIRS ${OpenCV_INCLUDE_DIRS} PARENT_SCOPE)

	LINK_DIRECTORIES(${OpenCV_LIB_DIR})
ENDFUNCTION(ADD_DEPENDENCY_TO_OPEN_CV)


FUNCTION(ADD_DEPENDENCY_TO_LEPTONICA)
    FIND_PACKAGE(Leptonica QUIET)
    IF(NOT ${Leptonica_FOUND})
        SET(Leptonica_Source ${CMAKE_SOURCE_DIR}/leptonica)
        include(ExternalProject)
        ExternalProject_Add(
            leptonica
            GIT_REPOSITORY  "https://github.com/DanBloomberg/leptonica.git"
            GIT_TAG "master"
            UPDATE_COMMAND ""
            PATCH_COMMAND ""
            TEST_COMMAND ""
            BINARY_DIR "${Leptonica_Source}/bin"
            SOURCE_DIR "${Leptonica_Source}"
            CMAKE_ARGS
                -DCMAKE_INSTALL_PREFIX:PATH=${ROOT_DIR}/leptonica/install
        )
    
        add_library(libleptonica SHARED IMPORTED)
        
        set_property(TARGET libleptonica APPEND PROPERTY IMPORTED_CONFIGURATIONS DEBUG)
        set_target_properties(libleptonica PROPERTIES
            IMPORTED_IMPLIB_DEBUG "D:/Programowanie/Projects/C++/visiontext/leptonica/bin/src/Debug/leptonica-1.74.2d.lib"
            IMPORTED_LOCATION_DEBUG "D:/Programowanie/Projects/C++/visiontext/leptonica/bin/bin/Debug/leptonica-1.74.2d.dll"
        )
        
        set_property(TARGET libleptonica APPEND PROPERTY IMPORTED_CONFIGURATIONS RELEASE)
        set_target_properties(libleptonica PROPERTIES
            IMPORTED_IMPLIB_RELEASE "${Leptonica_Source}/bin/src/Release/leptonica-1.74.2.lib"
            IMPORTED_LOCATION_RELEASE "${Leptonica_Source}/bin/bin/Release/leptonica-1.74.2.dll"
        )
        
        SET(Leptonica_LIBS libleptonica PARENT_SCOPE)
    
    ELSE(${Leptonica_FOUND})
        SET(Leptonica_LIBS leptonica PARENT_SCOPE)
    ENDIF(NOT ${Leptonica_FOUND})

ENDFUNCTION(ADD_DEPENDENCY_TO_LEPTONICA)

FUNCTION(ADD_DEPENDENCY_TO_TESSERACT)
    FIND_PACKAGE(Tesseract REQUIRED)
    IF(NOT ${Tesseract_FOUND})
        MESSAGE(FATAL_ERROR "Unable to find the requested Tesseract libraries.")
    ENDIF(NOT ${Tesseract_FOUND})

    MESSAGE(STATUS "Using Tesseract version: ${Tesseract_VERSION}")
    MESSAGE(STATUS "Using Tesseract libraries from: ${Tesseract_LIBRARIES}")
    MESSAGE(STATUS "Using Tesseract headers from: ${Tesseract_INCLUDE_DIRS}")
    
	SET(Tesseract_LIBS libtesseract PARENT_SCOPE)
	SET(Tesseract_INCLUDE_DIRS ${Tesseract_INCLUDE_DIRS} PARENT_SCOPE)

ENDFUNCTION(ADD_DEPENDENCY_TO_TESSERACT)
