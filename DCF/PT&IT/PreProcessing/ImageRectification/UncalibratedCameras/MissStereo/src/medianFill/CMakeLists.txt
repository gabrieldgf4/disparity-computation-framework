CMAKE_MINIMUM_REQUIRED(VERSION 2.6)

PROJECT(medianFill)

SET(SRC
    median_disparity.cpp median_disparity.h
    main.cpp)

ADD_EXECUTABLE(medianFill ${SRC})

INCLUDE_DIRECTORIES(..)

IF(UNIX)
    SET_TARGET_PROPERTIES(medianFill PROPERTIES
                          COMPILE_FLAGS "-Wall -Wextra -Werror")
ENDIF(UNIX)

TARGET_LINK_LIBRARIES(medianFill IO)

INSTALL(FILES CMakeLists.txt ${SRC} DESTINATION src/medianFill)
