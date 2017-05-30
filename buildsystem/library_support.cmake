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
        MESSAGE("Unable to find the requested Leptonica libraries. Adding leptonica as dependency project.")
        SET(Leptonica_Source ${CMAKE_SOURCE_DIR}/leptonica)
        FILE(MAKE_DIRECTORY ${CMAKE_LIBRARY_OUTPUT_DIRECTORY}/leptonica)
        
        INCLUDE(ExternalProject)
        ExternalProject_Add(
            leptonica
            GIT_REPOSITORY  "https://github.com/DanBloomberg/leptonica.git"
            GIT_TAG "master"
            UPDATE_COMMAND ""
            PATCH_COMMAND ""
            TEST_COMMAND ""
            BINARY_DIR "${CMAKE_LIBRARY_OUTPUT_DIRECTORY}/leptonica"
            SOURCE_DIR "${Leptonica_Source}"
            CMAKE_ARGS
                -DCMAKE_INSTALL_PREFIX:PATH=${Leptonica_Source}/install
                -DSTATIC=TRUE
        )
        
        ADD_LIBRARY(libleptonica SHARED IMPORTED)
        
        set_property(TARGET libleptonica APPEND PROPERTY IMPORTED_CONFIGURATIONS DEBUG)
        set_target_properties(libleptonica PROPERTIES
            IMPORTED_IMPLIB_DEBUG "${CMAKE_LIBRARY_OUTPUT_DIRECTORY}/leptonica/src/Debug/leptonica-1.74.2d.lib"
        )
        
        set_property(TARGET libleptonica APPEND PROPERTY IMPORTED_CONFIGURATIONS RELEASE)
        set_target_properties(libleptonica PROPERTIES
            IMPORTED_IMPLIB_RELEASE "${CMAKE_LIBRARY_OUTPUT_DIRECTORY}/leptonica/src/Release/leptonica-1.74.2.lib"
        )
        
        SET(EXTERNAL_PROJECTS ${EXTERNAL_PROJECTS};leptonica PARENT_SCOPE)
        SET(Leptonica_LIBS libleptonica PARENT_SCOPE)
    
    ELSE(${Leptonica_FOUND})
        SET(Leptonica_LIBS leptonica PARENT_SCOPE)
        
    ENDIF(NOT ${Leptonica_FOUND})
    
ENDFUNCTION(ADD_DEPENDENCY_TO_LEPTONICA)


FUNCTION(ADD_DEPENDENCY_TO_TESSERACT)
    FIND_PACKAGE(Tesseract QUIET)
    IF(NOT ${Tesseract_FOUND})
        MESSAGE("Unable to find the requested Tesseract libraries. Adding tesseract as dependency project.")
        SET(Tesseract_Source ${CMAKE_SOURCE_DIR}/tesseract)
        FILE(MAKE_DIRECTORY ${CMAKE_LIBRARY_OUTPUT_DIRECTORY}/tesseract)
        
        INCLUDE(ExternalProject)
        ExternalProject_Add(
            tesseract
            GIT_REPOSITORY  "https://github.com/tesseract-ocr/tesseract.git"
            GIT_TAG "master"
            UPDATE_COMMAND ""
            PATCH_COMMAND ""
            TEST_COMMAND ""
            BUILD_COMMAND "${CMAKE_COMMAND}" --build . --target libtesseract --config Debug &&
                          "${CMAKE_COMMAND}" --build . --target libtesseract --config Release
            INSTALL_COMMAND ""
            BINARY_DIR "${CMAKE_LIBRARY_OUTPUT_DIRECTORY}/tesseract"
            SOURCE_DIR "${Tesseract_Source}"
            CMAKE_ARGS
                -DCMAKE_INSTALL_PREFIX:PATH=${ROOT_DIR}/tesseract/install
                -DLeptonica_DIR=${CMAKE_SOURCE_DIR}/leptonica/install/cmake
                -DBUILD_TRAINING_TOOLS=FALSE
                -DSTATIC=TRUE
        )
        
        ADD_LIBRARY(libtesseract SHARED IMPORTED)
        
        set_property(TARGET libtesseract APPEND PROPERTY IMPORTED_CONFIGURATIONS DEBUG)
        set_target_properties(libtesseract PROPERTIES
            IMPORTED_IMPLIB_DEBUG "${CMAKE_LIBRARY_OUTPUT_DIRECTORY}/tesseract/Debug/tesseract400d.lib"
        )
        
        set_property(TARGET libtesseract APPEND PROPERTY IMPORTED_CONFIGURATIONS RELEASE)
        set_target_properties(libtesseract PROPERTIES
            IMPORTED_IMPLIB_RELEASE "${CMAKE_LIBRARY_OUTPUT_DIRECTORY}/tesseract/Release/tesseract400.lib"
        )
        
        SET(EXTERNAL_PROJECTS ${EXTERNAL_PROJECTS};tesseract PARENT_SCOPE)
        SET(Tesseract_LIBS libtesseract Ws2_32.lib PARENT_SCOPE)
        SET(Tesseract_INCLUDE_DIRS 
            ${Tesseract_Source}/api
            ${Tesseract_Source}/arch
            ${Tesseract_Source}/ccmain
            ${Tesseract_Source}/ccstruct
            ${Tesseract_Source}/ccutil
            ${Tesseract_Source}/lstm
            PARENT_SCOPE)
              
    ELSE(${Tesseract_FOUND})
        MESSAGE(STATUS "Using Tesseract version: ${Tesseract_VERSION}")
        MESSAGE(STATUS "Using Tesseract libraries from: ${Tesseract_LIBRARIES}")
        MESSAGE(STATUS "Using Tesseract headers from: ${Tesseract_INCLUDE_DIRS}")
        
        SET(Tesseract_LIBS libtesseract PARENT_SCOPE)
        SET(Tesseract_INCLUDE_DIRS ${Tesseract_INCLUDE_DIRS} PARENT_SCOPE)
    ENDIF(NOT ${Tesseract_FOUND})
ENDFUNCTION(ADD_DEPENDENCY_TO_TESSERACT)


FUNCTION(ADD_DEPENDENCY_TO_GTEST)
    SET(Googletest_Source ${CMAKE_SOURCE_DIR}/googletest)
    FILE(MAKE_DIRECTORY ${CMAKE_LIBRARY_OUTPUT_DIRECTORY}/googletest)

    
    INCLUDE(ExternalProject)
    ExternalProject_Add(googletest
          GIT_REPOSITORY    https://github.com/google/googletest.git
          GIT_TAG           master
          UPDATE_COMMAND ""
          PATCH_COMMAND ""
          TEST_COMMAND ""
          SOURCE_DIR        "${Googletest_Source}"
          BINARY_DIR        "${CMAKE_LIBRARY_OUTPUT_DIRECTORY}/googletest"
          CMAKE_ARGS
            -DCMAKE_INSTALL_PREFIX:PATH=${Googletest_Source}/install
            -Dgtest_force_shared_crt=TRUE
    )
    
    ADD_LIBRARY(libgoogletest SHARED IMPORTED)
        
    set_property(TARGET libgoogletest APPEND PROPERTY IMPORTED_CONFIGURATIONS DEBUG)
    set_target_properties(libgoogletest PROPERTIES
        IMPORTED_IMPLIB_DEBUG "${Googletest_Source}/install/lib/gtest.lib"
    )
    
    set_property(TARGET libgoogletest APPEND PROPERTY IMPORTED_CONFIGURATIONS RELEASE)
    set_target_properties(libgoogletest PROPERTIES
        IMPORTED_IMPLIB_RELEASE "${Googletest_Source}/install/lib/gtest.lib"
    )
    
    add_library(libgoogletest_main SHARED IMPORTED)
        
    set_property(TARGET libgoogletest_main APPEND PROPERTY IMPORTED_CONFIGURATIONS DEBUG)
    set_target_properties(libgoogletest_main PROPERTIES
        IMPORTED_IMPLIB_DEBUG "${Googletest_Source}/install/lib/gtest_main.lib"
    )
    
    set_property(TARGET libgoogletest_main APPEND PROPERTY IMPORTED_CONFIGURATIONS RELEASE)
    set_target_properties(libgoogletest_main PROPERTIES
        IMPORTED_IMPLIB_RELEASE "${Googletest_Source}/install/lib/gtest_main.lib"
    )
        
	SET(GTest_LIBS libgoogletest libgoogletest_main PARENT_SCOPE)
    SET(GTEST_INCLUDE_DIRS ${Googletest_Source}/install/include PARENT_SCOPE)
ENDFUNCTION(ADD_DEPENDENCY_TO_GTEST)

