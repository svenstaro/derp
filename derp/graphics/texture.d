/**
 * Loading and binding textures.
 */

module derp.graphics.texture;

import std.stdio;

import derelict.opengl3.gl3;
import derelict.devil.il;
import derelict.devil.ilu;
import derelict.devil.ilut;

import derp.math.all;
import derp.core.geo;
import derp.core.resources;
import derp.graphics.util;
import derp.graphics.view;

class Texture {
    uint ilHandle;
    uint glHandle;

    vec2i size;
    uint bitsPerPixel;
    int format;
    
    this() {
    }
    
    this(Resource r) {
        loadFromResource(r);
    }
    
    this(byte[] data) {
        loadFromMemory(data);
    }
    
    void loadFromResource(Resource r) {
        this.loadFromMemory(cast(byte[])r.bytes);
    }

    void loadFromMemory(byte[] data) {
        _create();

        _ilBind();
        ilLoadL(IL_TYPE_UNKNOWN, data.ptr, cast(uint)data.length);
        ilCheck();

        // Receive image information
        size.x = ilGetInteger(IL_IMAGE_WIDTH);
        size.y = ilGetInteger(IL_IMAGE_HEIGHT);
        bitsPerPixel = ilGetInteger(IL_IMAGE_BPP) * 8; // DevIL returns *bytes* per pixel
        format = ilGetInteger(IL_IMAGE_FORMAT);

        // writefln("Found image data: %s x %s x %s", size.x, size.y, bitsPerPixel);

        // Push data to OpenGL
        bind(); 
        glTexImage2D(GL_TEXTURE_2D, 0, bitsPerPixel / 8, size.x, size.y, 0, format, GL_UNSIGNED_BYTE, ilGetData());
        glCheck();
        unbind();

        // Cleanup
        //_ilUnbind();
        //glBindTexture(GL_TEXTURE_2D, 0);
        //ilDeleteImages(1, &ilHandle); // Because we have already copied image data into texture data we can release memory used by image.
    }

    void bind() {
        glBindTexture(GL_TEXTURE_2D, glHandle);
        glCheck();
    }

    void unbind() {
        glBindTexture(GL_TEXTURE_2D, 0);
        glCheck();
    }

private:
    void _create() {
        ilGenImages(1, &ilHandle);
        ilCheck();

        glGenTextures(1, &glHandle);
        glCheck();
    }

    void _ilBind() {
        ilBindImage(ilHandle);
        ilCheck();
    }

    void _ilUnbind() {
        ilBindImage(0);
        ilCheck();
    }
}
