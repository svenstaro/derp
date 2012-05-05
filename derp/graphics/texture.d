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
private:
    uint _ilHandle;
    uint _glHandle;

    vec2i _size;
    uint _bitsPerPixel;
    int _format;

    bool _initialized = false;

public:
    bool isRawData = false;

    @property vec2i size() {
        this.initialize();
        return this._size;
    }

    @property uint bitsPerPixel() {
        this.initialize();
        return this._bitsPerPixel;
    }

    @property uint format() {
        this.initialize();
        return this._format;
    }

    void initialize() {
        if(this._initialized) return;
        this._create();

        // this is the only place we need the data, so it must be loaded beyond this point
        this.required = true; 

        void* rawData;
        bool useRawData;
        if(this.isRawData) {
            ResourceSettings s;
            try {
                s = cast(ResourceSettings)this.source;
            } catch(Exception e) {
                assert(false, "Cannot read raw data - source is not ResourceSettings. You need it to set the `width` and `height` parameters.");
            }

            this._size.x = s.get!int("width", 0);
            this._size.y = s.get!int("height", 0);
            assert(this._size.x > 0 && this._size.y > 0, "Texture needs `width` and `height` parameters in ResourceSettings. You may also set `this.useRawData` to false to read the metadata from formatted metadata (e.g. if you have raw PNG or JPG data instead of raw pixel data).");

            string mode = s.get("mode", "rgba");
            if(mode == "rgba") {
                this._bitsPerPixel = 32;
                this._format = GL_RGBA;
            } else if(mode == "rgb") {
                this._bitsPerPixel = 24;
                this._format = GL_RGB;
            } else if(mode == "alpha") {
                this._bitsPerPixel = 8;
                this._format = GL_ALPHA;
            }

            this._bitsPerPixel = ilGetInteger(IL_IMAGE_BPP) * 8; // DevIL returns *bytes* per pixel
            this._format = GL_RGBA;
            rawData = &this.data[0];
        } else {
            this._ilBind();
            ilLoadL(IL_TYPE_UNKNOWN, this.data.ptr, cast(uint)this.data.length);
            rawData = ilGetData();
            ilCheck();
            // Receive image information
            this._size.x = ilGetInteger(IL_IMAGE_WIDTH);
            this._size.y = ilGetInteger(IL_IMAGE_HEIGHT);
            this._bitsPerPixel = ilGetInteger(IL_IMAGE_BPP) * 8; // DevIL returns *bytes* per pixel
            this._format = ilGetInteger(IL_IMAGE_FORMAT);
        }
        this.required = false; // we don't need the data anymore

        this._initialized = true;

        // writefln("Found image data: %s x %s x %s", size.x, size.y, bitsPerPixel);

        // Push data to OpenGL
        this.bind();
        glTexImage2D(GL_TEXTURE_2D, 0, 
                this._bitsPerPixel / 8, 
                this._size.x, this._size.y, 0, 
                this._format, GL_UNSIGNED_BYTE, rawData);
        glCheck();
        this.unbind();

        // Cleanup
        //_ilUnbind();
        //glBindTexture(GL_TEXTURE_2D, 0);
        //ilDeleteImages(1, &_ilHandle); // Because we have already copied image data into texture data we can release memory used by image.
    }

    void bind() {
        this.initialize(); // this may load the data

        glBindTexture(GL_TEXTURE_2D, _glHandle);
        glCheck();
    }

    void unbind() {
        glBindTexture(GL_TEXTURE_2D, 0);
        glCheck();
    }

private:
    void _create() {
        ilGenImages(1, &_ilHandle);
        ilCheck();

        glGenTextures(1, &_glHandle);
        glCheck();
    }

    void _ilBind() {
        ilBindImage(_ilHandle);
        ilCheck();
    }

    void _ilUnbind() {
        ilBindImage(0);
        ilCheck();
    }
}
