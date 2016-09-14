IF(OpenCV_DIR)
  FIND_PACKAGE(OpenCV 3.1.0 REQUIRED NO_MODULE)

  SET(PLUS_OpenCV_DIR ${OpenCV_DIR} CACHE INTERNAL "Path to store OpenCV binaries")
ELSE()
  # No OpenCV is specified, so download and build
  SET(OpenCV_REPOSITORY https://github.com/opencv/opencv.git)

  FIND_PACKAGE(CUDA QUIET)
  
  SET(OpenCV_PLATFORM_SPECIFIC_ARGS)
  IF(MSVC AND NOT ${CMAKE_GENERATOR} MATCHES "Win64")
    LIST(APPEND OpenCV_PLATFORM_SPECIFIC_ARGS -DWITH_CUDA:BOOL=OFF)
  ELSE()
    IF(CUDA_FOUND)
      LIST(APPEND OpenCV_PLATFORM_SPECIFIC_ARGS -DWITH_CUDA:BOOL=ON)
    ELSE()
      LIST(APPEND OpenCV_PLATFORM_SPECIFIC_ARGS -DWITH_CUDA:BOOL=OFF)
    ENDIF()
  ENDIF()
  
  IF(Qt5_FOUND)
    LIST(APPEND OpenCV_PLATFORM_SPECIFIC_ARGS -DWITH_QT:BOOL=ON -DQt5_DIR:PATH=${Qt5_DIR})
  ENDIF()

  MESSAGE(STATUS "Downloading OpenCV from: ${OpenCV_REPOSITORY}")

  SET (PLUS_OpenCV_src_DIR ${CMAKE_BINARY_DIR}/Deps/OpenCV CACHE INTERNAL "Path to store OpenCV contents.")
  SET (PLUS_OpenCV_prefix_DIR ${CMAKE_BINARY_DIR}/Deps/OpenCV-prefix CACHE INTERNAL "Path to store OpenCV prefix data.")
  SET (PLUS_OpenCV_DIR ${CMAKE_BINARY_DIR}/Deps/OpenCV-bin CACHE INTERNAL "Path to store OpenCV binaries")
  ExternalProject_Add( OpenCV
      PREFIX ${PLUS_OpenCV_prefix_DIR}
      "${PLUSBUILD_EXTERNAL_PROJECT_CUSTOM_COMMANDS}"
      SOURCE_DIR "${PLUS_OpenCV_src_DIR}"
      BINARY_DIR "${PLUS_OpenCV_DIR}"
      #--Download step--------------
      GIT_REPOSITORY ${OpenCV_REPOSITORY}
      GIT_TAG 3.1.0
      #--Configure step-------------
      CMAKE_ARGS
          ${ep_common_args}
          ${OpenCV_PLATFORM_SPECIFIC_ARGS}
          -DCMAKE_CXX_FLAGS:STRING=${ep_common_cxx_flags}
          -DCMAKE_C_FLAGS:STRING=${ep_common_c_flags}
          -DBUILD_SHARED_LIBS:BOOL=${PLUSBUILD_BUILD_SHARED_LIBS}
      #--Build step-----------------
      BUILD_ALWAYS 1
      #--Install step-----------------
      INSTALL_COMMAND "" # Do not install, we have access to ${PLUS_OpenCV_DIR}/OpenCVConfig.cmake
      #--Dependencies-----------------
      DEPENDS ${OpenCV_DEPENDENCIES}
      )
ENDIF()