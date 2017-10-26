function(add_python_test test)
    add_test(NAME ${test} COMMAND ${PYTHON_EXECUTABLE} ${test}.py)
    set_tests_properties(${test} PROPERTIES ENVIRONMENT "PYTHONPATH=${CMAKE_BINARY_DIR}/swig:$ENV{PYTHONPATH}" DEPENDS "ctest_build_test_code;ctest_copy_pure_python_modules;ctest_copy_test_files")
endfunction(add_python_test)

set(TEST_DIR ${CMAKE_BINARY_DIR}/test)

# Copy pure python module files into test dir
file(COPY ${CMAKE_SOURCE_DIR}/swig/ DESTINATION ${CMAKE_BINARY_DIR}/swig/alps FILES_MATCHING PATTERN "*.py")

# Make sure modules are built before runing tests
add_test(ctest_build_test_code "${CMAKE_COMMAND}" --build ${CMAKE_BINARY_DIR})

# Copy pure python modules into swig/alps/
file(GLOB PURE_PYTHON_MODULES ${CMAKE_SOURCE_DIR}/swig/*.py)
add_custom_target(copy_pure_python_modules
    COMMAND ${CMAKE_COMMAND} -E copy ${PURE_PYTHON_MODULES} ${CMAKE_BINARY_DIR}/swig/alps
    DEPENDS ${PURE_PYTHON_MODULES})
message("DEBUG "  ${PURE_PYTHON_MODULES})
add_test(ctest_copy_pure_python_modules ${CMAKE_COMMAND} --build ${CMAKE_BINARY_DIR} --target copy_pure_python_modules)

# Copy all files used in tests into test/
file(GLOB TEST_PY_FILES *.py)
file(GLOB TEST_H5_FILES *.h5)
set(TEST_FILES ${TEST_PY_FILES} ${TEST_H5_FILES})
add_custom_target(copy_test_files
    COMMAND ${CMAKE_COMMAND} -E copy ${TEST_FILES} ${TEST_DIR}
    DEPENDS ${TEST_FILES})
add_test(ctest_copy_test_files ${CMAKE_COMMAND} --build ${CMAKE_BINARY_DIR} --target copy_test_files)

add_python_test(gf_test)
