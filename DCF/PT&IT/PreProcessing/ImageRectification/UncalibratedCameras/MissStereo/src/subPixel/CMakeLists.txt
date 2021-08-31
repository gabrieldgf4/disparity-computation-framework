CMAKE_MINIMUM_REQUIRED(VERSION 2.6)

PROJECT(subPixel)

SET(SRC
	fft.c fft.h
	subpixel.cpp subpixel.h
    main.cpp)

ADD_EXECUTABLE(subPixel ${SRC})

INCLUDE_DIRECTORIES(..)

IF(UNIX)
    SET_TARGET_PROPERTIES(subPixel PROPERTIES
                          COMPILE_FLAGS "")
ENDIF(UNIX)

TARGET_LINK_LIBRARIES(subPixel Transform Numerics IO)

INSTALL(FILES CMakeLists.txt ${SRC} DESTINATION src/subPixel)
