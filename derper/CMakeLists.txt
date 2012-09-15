FILE(GLOB_RECURSE DERPER_SOURCES *.d)

ADD_EXECUTABLE(derper
    ${DERPER_SOURCES}
)

ADD_DEPENDENCIES(derper derp)

TARGET_LINK_LIBRARIES(derper
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
