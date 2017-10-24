file(COPY ${CMAKE_CURRENT_SOURCE_DIR}/ DESTINATION ${CMAKE_BINARY_DIR}/test FILES_MATCHING PATTERN "*.py")
file(COPY ${CMAKE_CURRENT_SOURCE_DIR}/ DESTINATION ${CMAKE_BINARY_DIR}/test FILES_MATCHING PATTERN "*.h5")

# Copy pure python module files
file(COPY ${CMAKE_SOURCE_DIR}/swig/ DESTINATION ${CMAKE_BINARY_DIR}/test FILES_MATCHING PATTERN "*.py")

configure_file(${CMAKE_SOURCE_DIR}/cmake/sitecustomize.py ${CMAKE_CURRENT_BINARY_DIR}/sitecustomize.py @ONLY)

add_python_test(gf_test)
