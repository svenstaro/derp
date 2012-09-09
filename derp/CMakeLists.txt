FILE(GLOB_RECURSE DERP_SOURCES *.d)

ADD_LIBRARY(derp
    ${DERP_SOURCES}
)

TARGET_LINK_LIBRARIES(derp
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
