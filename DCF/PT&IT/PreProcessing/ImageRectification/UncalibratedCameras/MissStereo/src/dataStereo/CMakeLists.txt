CMAKE_MINIMUM_REQUIRED(VERSION 2.6)

SET(DATA pca_basis.dat prolate.dat)
INSTALL(FILES CMakeLists.txt ${DATA} DESTINATION src/dataStereo)
