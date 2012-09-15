FILE(GLOB_RECURSE HERPDERP_SOURCES *.d)

ADD_EXECUTABLE(herpderp
    ${HERPDERP_SOURCES}
)

ADD_DEPENDENCIES(herpderp derp)

TARGET_LINK_LIBRARIES(herpderp
    ${CMAKE_STATIC_LIBRARY_PREFIX}derp${CMAKE_STATIC_LIBRARY_SUFFIX}
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
