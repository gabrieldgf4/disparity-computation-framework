CMAKE_MINIMUM_REQUIRED(VERSION 2.6)

PROJECT(rectify)

INCLUDE_DIRECTORIES(..)

SET(SRC rectify.cpp)

ADD_EXECUTABLE(rectify ${SRC})

IF(UNIX)
    SET_TARGET_PROPERTIES(rectify PROPERTIES
                          COMPILE_FLAGS "-Wall -Wextra -Werror")
ENDIF(UNIX)

TARGET_LINK_LIBRARIES(rectify Numerics Match)

INSTALL(FILES CMakeLists.txt ${SRC} DESTINATION src/rectify)
