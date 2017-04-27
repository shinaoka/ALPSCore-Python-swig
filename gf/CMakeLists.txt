set(GF_SRCS
    gf_aux.hpp
)

set(GF_INTERFACE_FILES
    gf.i
)

set_source_files_properties(${GF_INTERFACE_FILES} PROPERTIES CPLUSPLUS ON)
swig_add_library(gf LANGUAGE python SOURCES ${GF_INTERFACE_FILES} ${GF_SRCS})
swig_link_libraries(gf ${PYTHON_LIBRARIES} ${ALPSCore_LIBRARIES})

include_directories(
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${PROJECT_BINARY_DIR}
    ${PYTHON_INCLUDE_PATH}
    ${NUMPY_INCLUDE_DIRS}
    ${ALPSCore_INCLUDE_DIR}
)

install(TARGETS _gf DESTINATION ${PYTHON_SITE_PACKAGES}/alps/gf)
install(FILES ${CMAKE_CURRENT_SOURCE_DIR}/__init__.py DESTINATION ${PYTHON_SITE_PACKAGES}/alps/gf)
