FILE(GLOB_RECURSE TESTS src/*.d)

FOREACH(test_src ${TESTS})
    STRING(REGEX REPLACE "(.*/src/|\\.d$)" "" test ${test_src})
    SET(test "test-${test}")
    MESSAGE("TEST: "${test})

    ADD_EXECUTABLE(${test} ${test_src})
    ADD_DEPENDENCIES(${test} derp)

    TARGET_LINK_LIBRARIES(${test}
        :${CMAKE_STATIC_LIBRARY_PREFIX}derp${CMAKE_STATIC_LIBRARY_SUFFIX}
        luajit-5.1
        dl
        curl
        luad
        orange
        DerelictAL
        DerelictFT
        DerelictGL3
        DerelictGLFW3
        DerelictIL
        DerelictUtil
        gl3n-dmd
    )
ENDFOREACH()

