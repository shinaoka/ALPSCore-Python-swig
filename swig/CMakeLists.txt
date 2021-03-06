function(add_alpscore_swig_module module_name interface_files aux_files)
    set_source_files_properties(${interface_files} PROPERTIES CPLUSPLUS ON)
    swig_add_module(${module_name} python ${interface_files} ${aux_files})
    swig_link_libraries(${module_name} ${SWIG_DEP_LIBRARIES})
    set_source_files_properties(${swig_generated_file_fullname} PROPERTIES COMPILE_FLAGS ${SWIG_EXTRA_COMPILE_FLAGS})
    install(TARGETS "_${module_name}" DESTINATION ${PYTHON_INSTALL_DIR}/alps)
    install(FILES "${CMAKE_SWIG_OUTDIR}/${module_name}.py" DESTINATION ${PYTHON_INSTALL_DIR}/alps)
endfunction()

set(SWIG_EXTRA_COMPILE_FLAGS  "-Wno-long-long -Wno-extra")
# TODO: Remove alps-transform and the corresponding link flag once alps-transform module becomes a part of ALPSCore officially.
set(SWIG_DEP_LIBRARIES ${PYTHON_LIBRARIES} ${ALPSCore_LIBRARIES} ${FFTW3_LIBRARIES} alps-transform)
link_directories("${CMAKE_INSTALL_PREFIX}/lib")
include_directories(
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${PROJECT_BINARY_DIR}
    ${PYTHON_INCLUDE_PATH}
    ${NUMPY_INCLUDE_DIRS}
    ${ALPSCore_INCLUDE_DIR}
)
set(CMAKE_SWIG_OUTDIR ${CMAKE_BINARY_DIR}/swig/alps)

add_alpscore_swig_module(gf gf.i gf_aux.hpp)
add_alpscore_swig_module(transform transform.i "")

# Install pure Python module files
file(GLOB PYTHON_FILES_SRC *.py)
install(FILES ${PYTHON_FILES_SRC} DESTINATION ${PYTHON_INSTALL_DIR}/alps)
