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

class Texture : Resource {
    uint ilHandle;
    uint glHandle;

    vec2i size;
    uint bitsPerPixel;
    int format;

    bool initialized = false;

    void initialize() {
        _create();

        _ilBind();
        this.required = true; // this is where we need the data, at lease
        ilLoadL(IL_TYPE_UNKNOWN, this.data.ptr, cast(uint)this.data.length);
        this.required = false;
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

        this.initialized = true;
        // Cleanup
        //_ilUnbind();
        //glBindTexture(GL_TEXTURE_2D, 0);
        //ilDeleteImages(1, &ilHandle); // Because we have already copied image data into texture data we can release memory used by image.
    }

    void bind() {
        if(!this.initialized) this.initialize(); // this may load the data

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
