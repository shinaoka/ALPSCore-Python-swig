cmake_minimum_required(VERSION 2.8 FATAL_ERROR)

# add common modules from ../common/cmake
list(APPEND CMAKE_MODULE_PATH ${PROJECT_SOURCE_DIR}/common/cmake)

find_package(PythonInterp REQUIRED)
find_package(PythonLibs REQUIRED)
message("FOUND Python executable: " ${PYTHON_EXECUTABLE})
message("FOUND Python libs: " ${PYTHON_LIBRARIES})

if (NOT PYTHON_VERSION_STRING STREQUAL PYTHONLIBS_VERSION_STRING)
    message(FATAL_ERROR "Versions of Python interpreter and libs do not match!")
endif()

find_package(NumPy REQUIRED)
message("FOUND NumPy: " ${NUMPY_INCLUDE_DIR})

find_package(SWIG REQUIRED)
include(${SWIG_USE_FILE})
include(GenerateExportHeader)

find_package(ALPSCore REQUIRED gf gf-extensions)

#Get include dirs from alps-gf (FIXME: take care of all ALPSCore modules)
get_target_property(ALPSCore_INCLUDE_DIR alps::alps-gf INTERFACE_INCLUDE_DIRECTORIES)

include_directories(
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${PROJECT_BINARY_DIR}
    ${PYTHON_INCLUDE_PATH}
    ${NUMPY_INCLUDE_DIRS}
    ${ALPSCore_INCLUDE_DIR}
)

message("Python include dirs: " ${PYTHON_INCLUDE_PATH})
message("Python libraries: " ${PYTHON_LIBRARIES})

set(EXAM_SRCS
    gf_aux.hpp
)

set(INTERFACE_FILES
    gf.i
)

set_source_files_properties(${INTERFACE_FILES} PROPERTIES CPLUSPLUS ON)
swig_add_library(gf LANGUAGE python SOURCES ${INTERFACE_FILES} ${EXAM_SRCS})

swig_link_libraries(gf ${PYTHON_LIBRARIES} ${ALPSCore_LIBRARIES})

execute_process(COMMAND ${PYTHON_EXECUTABLE} -c "from distutils.sysconfig import get_python_lib; print get_python_lib()" OUTPUT_VARIABLE PYTHON_SITE_PACKAGES OUTPUT_STRIP_TRAILING_WHITESPACE)
message("PYTHON_SITE_PACKAGES" ${PYTHON_SITE_PACKAGES})
install(TARGETS _gf DESTINATION ${PYTHON_SITE_PACKAGES})
#install(FILES ${CMAKE_BINARY_DIR}/src/target.py DESTINATION ${PYTHON_SITE_PACKAGES})
