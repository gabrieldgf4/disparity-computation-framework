CMAKE_MINIMUM_REQUIRED(VERSION 2.6)

PROJECT(stereoAC)

SET(SRC
	stereoAC.cpp stereoAC.h
    main.cpp)

ADD_EXECUTABLE(stereoAC ${SRC})

INCLUDE_DIRECTORIES(..)

IF(UNIX)
    SET_TARGET_PROPERTIES(stereoAC PROPERTIES
                          COMPILE_FLAGS "-Wall -Wextra -Werror")
ENDIF(UNIX)

TARGET_LINK_LIBRARIES(stereoAC Stereo IO)

INSTALL(FILES CMakeLists.txt ${SRC} DESTINATION src/stereoAC)
