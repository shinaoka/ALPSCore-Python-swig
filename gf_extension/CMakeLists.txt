set(GF_SRCS
)

set(GF_INTERFACE_FILES
    gf_extension.i
)

set_source_files_properties(${GF_INTERFACE_FILES} PROPERTIES CPLUSPLUS ON)
swig_add_library(gf_extension LANGUAGE python SOURCES ${GF_INTERFACE_FILES} ${GF_SRCS})
swig_link_libraries(gf_extension ${PYTHON_LIBRARIES} ${ALPSCore_LIBRARIES})

include_directories(
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${PROJECT_BINARY_DIR}
    ${PYTHON_INCLUDE_PATH}
    ${NUMPY_INCLUDE_DIRS}
    ${ALPSCore_INCLUDE_DIR}
)

install(TARGETS _gf_extension DESTINATION ${PYTHON_SITE_PACKAGES}/alps)
install(FILES ${CMAKE_CURRENT_SOURCE_DIR}/__init__.py DESTINATION ${PYTHON_SITE_PACKAGES}/alps)
install(FILES ${CMAKE_CURRENT_BINARY_DIR}/gf_extension.py DESTINATION ${PYTHON_SITE_PACKAGES}/alps)
#install(TARGETS _gf_extension DESTINATION ${PYTHON_SITE_PACKAGES}/alps/gf_extension)
#install(FILES ${CMAKE_CURRENT_SOURCE_DIR}/__init__.py DESTINATION ${PYTHON_SITE_PACKAGES}/alps/gf_extension)
#install(FILES ${CMAKE_CURRENT_BINARY_DIR}/gf_extension.py DESTINATION ${PYTHON_SITE_PACKAGES}/alps/gf_extension)
