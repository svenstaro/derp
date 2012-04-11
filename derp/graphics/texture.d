/**
 * Loading and binding textures.
 */

module derp.graphics.texture;

import std.stdio;

import derelict.opengl3.gl3;
import derelict.devil.il;
import derelict.devil.ilu;
import derelict.devil.ilut;

import derp.core.geo;
import derp.graphics.util;
import derp.graphics.view;

class Texture {
    uint ilHandle;
    uint glHandle;

    vec2i size;
    uint bitsPerPixel;
    int format;

    void loadFromMemory(byte[] data) {
        _create();

        _ilBind();
        ilLoadL(IL_TYPE_UNKNOWN, data.ptr, cast(uint)data.length);
        ilCheck();

        // Receive image information
        size.x = ilGetInteger(IL_IMAGE_WIDTH);
        size.y = ilGetInteger(IL_IMAGE_HEIGHT);
        bitsPerPixel = ilGetInteger(IL_IMAGE_BPP);
        format = ilGetInteger(IL_IMAGE_FORMAT);

        writefln("Found image data: %s x %s  at  %s BPP", size.x, size.y, bitsPerPixel);
        if(format == GL_RGBA) writeln("RGBA");
        else writeln("Not rgba.");

        // Push data to OpenGL
        glBindTexture(GL_TEXTURE_2D, glHandle);
        glCheck();

        // glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        // glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);

        /*iluImageParameter(ILU_PLACEMENT, ILU_UPPER_LEFT);
        int nextPow2(int x) {
            int i = 1;
            while(x > i) i *= 2;
            return x == i ? i : i * 2;
        }
        iluEnlargeCanvas(nextPow2(size.x), nextPow2(size.y), bitsPerPixel);

        int w = ilGetInteger(IL_IMAGE_WIDTH);
        int h = ilGetInteger(IL_IMAGE_HEIGHT);*/
        glTexImage2D(GL_TEXTURE_2D, 0, bitsPerPixel, size.x, size.y, 0, format, GL_UNSIGNED_BYTE, ilGetData());
        glCheck();

        // Cleanup
        //_ilUnbind();
        //glBindTexture(GL_TEXTURE_2D, 0);
        //ilDeleteImages(1, &ilHandle); // Because we have already copied image data into texture data we can release memory used by image.
    }

    void bind() {
        glBindTexture(GL_TEXTURE_2D, glHandle);
    }

    void unbind() {
        glBindTexture(GL_TEXTURE_2D, 0);
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
