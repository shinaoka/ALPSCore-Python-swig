cmake_minimum_required(VERSION 2.8 FATAL_ERROR)

# add common modules from ../common/cmake
list(APPEND CMAKE_MODULE_PATH ${PROJECT_SOURCE_DIR}/common/cmake)

set(CMAKE_MACOSX_RPATH 1)
SET(CMAKE_INSTALL_RPATH_USE_LINK_PATH TRUE)

#If this does not find the correct one, please use invoke cmake with -DPYTHON_EXECUTABLE=/path/to/your/python/executable.
find_package(PythonInterp REQUIRED)
message("Found Python executable: " ${PYTHON_EXECUTABLE})
message("Python version: " ${PYTHON_VERSION_STRING})

#execute_process(COMMAND ${PYTHON_EXECUTABLE} -c "from distutils import sysconfig;print sysconfig.get_config_var(\"LIBDIR\")" OUTPUT_VARIABLE PYTHON_LIBDIR OUTPUT_STRIP_TRA ILING_WHITESPACE)

#find_package(PythonLibs EXACT ${PYTHON_VERSION_STRING} REQUIRED)
find_package(PythonLibs REQUIRED)
message("Found Python libs: " ${PYTHON_LIBRARIES})
message("Python libs version: " ${PYTHONLIBS_VERSION_STRING})
message("Python libraries: " ${PYTHON_LIBRARIES})
message("Python include dirs: " ${PYTHON_INCLUDE_DIRS})

if (NOT PYTHONLIBS_VERSION_STRING STREQUAL PYTHON_VERSION_STRING)
    message(FATAL_ERROR "Version mismatch between Python interpreter and libs")
endif()

find_package(NumPy REQUIRED)
message("Found NumPy: " ${NUMPY_INCLUDE_DIR})
message("NumPy include dirs: " ${PYTHON_NUMPY_INCLUDE_DIR})

find_package(SWIG REQUIRED 3.0)
include(${SWIG_USE_FILE})
include(GenerateExportHeader)

find_package(ALPSCore REQUIRED gf)

#Get include dirs from alps-gf (FIXME: take care of all ALPSCore modules)
get_target_property(ALPSCore_INCLUDE_DIR alps::alps-gf INTERFACE_INCLUDE_DIRECTORIES)

include_directories(
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${PROJECT_BINARY_DIR}
    ${PYTHON_INCLUDE_PATH}
    ${NUMPY_INCLUDE_DIRS}
    ${ALPSCore_INCLUDE_DIR}
)

execute_process(COMMAND ${PYTHON_EXECUTABLE} -c "from distutils.sysconfig import get_python_lib; print get_python_lib()" OUTPUT_VARIABLE PYTHON_SITE_PACKAGES OUTPUT_STRIP_TRAILING_WHITESPACE)

# Set install directory
string(REGEX MATCH "^[0-9]+\\.[0-9]+" PYTHON_VERSION
       "${PYTHONLIBS_VERSION_STRING}")
set(PYTHON_INSTALL_DIR "lib/python${PYTHON_VERSION}/site-packages"
        CACHE PATH "Path for installing the python packages")

add_subdirectory(swig)

# Enable tests
#include(EnableTests)
# Build and enable tests
# testing setup
# enable_testing() must be called in the top-level CMakeLists.txt before any add_subdirectory() is called.
option(Testing "Enable testing" ON)
if (Testing)
    include(EnableTests) #defined in ./cmake
    enable_testing(test)
    add_subdirectory(test)
endif()


