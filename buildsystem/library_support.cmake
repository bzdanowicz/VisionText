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
                -DCMAKE_INSTALL_PREFIX:PATH=${Leptonica_Source}/install
                -DSTATIC=TRUE
        )
    
        add_library(libleptonica SHARED IMPORTED)
        
        set_property(TARGET libleptonica APPEND PROPERTY IMPORTED_CONFIGURATIONS DEBUG)
        set_target_properties(libleptonica PROPERTIES
            IMPORTED_IMPLIB_DEBUG "${Leptonica_Source}/bin/src/Debug/leptonica-1.74.2d.lib"
            IMPORTED_LOCATION_DEBUG "${Leptonica_Source}bin/Debug/leptonica-1.74.2d.dll"
        )
        
        set_property(TARGET libleptonica APPEND PROPERTY IMPORTED_CONFIGURATIONS RELEASE)
        set_target_properties(libleptonica PROPERTIES
            IMPORTED_IMPLIB_RELEASE "${Leptonica_Source}/bin/src/Release/leptonica-1.74.2.lib"
            IMPORTED_LOCATION_RELEASE "${Leptonica_Source}/bin/bin/Release/leptonica-1.74.2.dll"
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
        include(ExternalProject)
        ExternalProject_Add(
            tesseract
            GIT_REPOSITORY  "https://github.com/tesseract-ocr/tesseract.git"
            GIT_TAG "master"
            UPDATE_COMMAND ""
            PATCH_COMMAND ""
            TEST_COMMAND ""
            BUILD_COMMAND "${CMAKE_COMMAND}" --build . --target libtesseract
            INSTALL_COMMAND ""
            BINARY_DIR "${Tesseract_Source}/bin"
            SOURCE_DIR "${Tesseract_Source}"
            CMAKE_ARGS
                -DCMAKE_INSTALL_PREFIX:PATH=${ROOT_DIR}/tesseract/install
                -DLeptonica_DIR=${CMAKE_SOURCE_DIR}/leptonica/install/cmake
                -DBUILD_TRAINING_TOOLS=FALSE
                -DSTATIC=TRUE
        )
        
        add_library(libtesseract SHARED IMPORTED)
        
        set_property(TARGET libtesseract APPEND PROPERTY IMPORTED_CONFIGURATIONS DEBUG)
        set_target_properties(libtesseract PROPERTIES
            IMPORTED_IMPLIB_DEBUG "${Tesseract_Source}/bin/Debug/tesseract400d.lib"
            IMPORTED_LOCATION_DEBUG "${Tesseract_Source}/bin/bin/Debug/tesseract400d.dll"
        )
        
        set_property(TARGET libtesseract APPEND PROPERTY IMPORTED_CONFIGURATIONS RELEASE)
        set_target_properties(libtesseract PROPERTIES
            IMPORTED_IMPLIB_RELEASE "${Tesseract_Source}/bin/Release/tesseract400.lib"
            IMPORTED_LOCATION_RELEASE "${Tesseract_Source}/bin/bin/Release/tesseract400.dll"
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

