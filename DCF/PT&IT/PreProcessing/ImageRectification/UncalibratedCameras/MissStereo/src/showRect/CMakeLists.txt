CMAKE_MINIMUM_REQUIRED(VERSION 2.6)

PROJECT(showRect)

SET(SRC showRect.cpp)

ADD_EXECUTABLE(showRect ${SRC})

INCLUDE_DIRECTORIES(..)

IF(UNIX)
    SET_TARGET_PROPERTIES(showRect PROPERTIES
                          COMPILE_FLAGS "-Wall -Wextra -Werror")
ENDIF(UNIX)

TARGET_LINK_LIBRARIES(showRect IO Transform Match Numerics)

INSTALL(FILES CMakeLists.txt ${SRC} DESTINATION src/showRect)
