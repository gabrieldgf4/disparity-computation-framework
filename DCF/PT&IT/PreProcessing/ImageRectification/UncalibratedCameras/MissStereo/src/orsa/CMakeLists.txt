CMAKE_MINIMUM_REQUIRED(VERSION 2.6)

PROJECT(orsa)

INCLUDE_DIRECTORIES(..)

SET(SRC orsa.cpp orsa.h main.cpp)

ADD_EXECUTABLE(orsa ${SRC})

IF(UNIX)
    SET_TARGET_PROPERTIES(orsa PROPERTIES
                          COMPILE_FLAGS "-Wall -Wextra -Werror")
ENDIF(UNIX)

TARGET_LINK_LIBRARIES(orsa Match Numerics)

INSTALL(FILES CMakeLists.txt ${SRC} DESTINATION src/orsa)
