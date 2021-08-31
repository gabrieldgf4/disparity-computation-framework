CMAKE_MINIMUM_REQUIRED(VERSION 2.6)

PROJECT(selfSimilar)

SET(SRC selfSimilar.cpp selfSimilar.h main.cpp)

ADD_EXECUTABLE(selfSimilar ${SRC})

INCLUDE_DIRECTORIES(..)

IF(UNIX)
    SET_TARGET_PROPERTIES(selfSimilar PROPERTIES
                          COMPILE_FLAGS "-Wall -Wextra -Werror")
ENDIF(UNIX)

TARGET_LINK_LIBRARIES(selfSimilar Stereo IO)

INSTALL(FILES CMakeLists.txt ${SRC} DESTINATION src/selfSimilar)
