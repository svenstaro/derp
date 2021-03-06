module derp.graphics.text;

import std.stdio;
import std.math;

import derelict.freetype.ft;

import derp.core.resources;
import derp.core.scene;
import derp.math.vector;
import derp.graphics.draw;
import derp.graphics.render;
import derp.graphics.shader;
import derp.graphics.sprite;
import derp.graphics.texture;
import derp.graphics.util;
import derp.graphics.vertexbuffer;

/** 
 * Resolution of the display device. You may set a different value before
 * loading a font if your display does not have a resolution of 72 dpi (pixels
 * per inch).
 */
uint screenDpi = 72;

class Font : Resource {
private:
    bool _initialized = false;
public:
    FT_Face fontFace;
    int pointSize = 12;

    /*this(int pointSize = 12) {
        this.pointSize = pointSize;
    }*/

    @property int pixelSize() {
        return cast(int)round(this.pointSize * screenDpi / 72);
    }

    @property void pixelSize(int pixelSize) {
        this.pointSize = cast(int)round(pixelSize / 72.0 * screenDpi);
    }

    void initialize() {
        if(this._initialized) return;
        this.required = true;
        ubyte[] d = cast(ubyte[])this.data;
        ftCheck(FT_New_Memory_Face(freetypeLibrary, &d[0],
                this.data.length, 0, &this.fontFace));
        ftCheck(FT_Set_Char_Size(this.fontFace, 0, pointSize * 64, 
                screenDpi, screenDpi));
        // maybe it's better to use FT_Set_Pixel_Sizes
        this.required = false;
        this._initialized = true;
    }

    uint getCharacterIndex(char character) {
        return FT_Get_Char_Index(this.fontFace, character);
    }

    FT_GlyphSlot render(char character, bool loadOnly = false) {
        this.initialize();
        ftCheck(FT_Load_Glyph(this.fontFace, this.getCharacterIndex(character), 0));
        if(!loadOnly) {
            ftCheck(FT_Render_Glyph(this.fontFace.glyph, FT_Render_Mode.FT_RENDER_MODE_NORMAL));
        }
        return this.fontFace.glyph;
    }
}

class FontRenderer : ResourceGenerator {
    Font font;
    this(Font font) {
        this.font = font; 
    }

    vec2i getSize(string text) {
        float w = 0;
        foreach(char c; text) {
            FT_GlyphSlot slot = this.font.render(c, true); // load, but don't render
            w += slot.advance.x / 64;
        }
        float h = this.font.fontFace.size.metrics.height / 64;
        return vec2i(cast(int)ceil(w), cast(int)ceil(h) + 1);
    }

    byte[] generate(ResourceSettings settings) {
        string text = settings.get("text");

        vec2i texSize = this.getSize(text);
        
        settings.set!int("width", texSize.x);
        settings.set!int("height", texSize.y);
        settings.set!string("mode", "rgba");

        // pen position in pixels
        int pen_x = 0; 
        int pen_y = cast(int)(this.font.fontFace.size.metrics.ascender / 64);

        // create empty bitmap
        byte[] bitmap = new byte[texSize.x * texSize.y * 4];
        for(int i = 0; i < texSize.x * texSize.y * 4; i += 4) {
            bitmap[i + 0] = bitmap[i + 1] = bitmap[i + 2] = cast(byte)255;
            bitmap[i + 3] = cast(byte)0;
        }

        // calculate size

        foreach(char c; text) {
            FT_GlyphSlot slot = this.font.render(c);

            // Draw glyph to bitmap
            int w = slot.bitmap.width;
            int h = slot.bitmap.rows;

            int x = pen_x + slot.bitmap_left;
            int y = pen_y - slot.bitmap_top;

            for(int j = 0; j < h; ++j) {
                for(int i = 0; i < w; ++i) {
                    bitmap[3 + 4 * (x + i + (y + j) * texSize.x)] = slot.bitmap.buffer[i + j * w];
                }
            }

            // Move pen
            pen_x += slot.advance.x / 64;
            pen_y += slot.advance.y / 64;
        }
        return bitmap;
    }
}

class TextComponent : SpriteComponent {
private:
    //Texture _texture;
    string _text;
    Font _font;
    bool _needRender = true;

public:
    this(string name, string text = "", Font font = null) {
        this.text = text;
        this.font = font;
        this._render();
        super(name, this._texture);
        this.scale = 1;
    }

    @property string text() {
        return this._text;
    }

    @property void text(string text) {
        this._needRender = text != this._text;
        this._text = text;
    }

    @property Font font() {
        return this._font;
    }

    @property void font(Font font) {
        this._font = font;
        this._needRender = true;
    }

    void render(RenderQueue queue) {
        if(this._needRender) {
            this._render();
        }

        super.render(queue);
    }

private:
    void _render() {
        ResourceManager mgr = new ResourceManager();
        FontRenderer renderer = new FontRenderer(this.font);
        mgr.registerLoader("font-renderer", renderer);
        this._texture = mgr.loadT!Texture(
                new ResourceSettings("text", this.text), // renderer will set dimensions
                renderer, "text");
        this._texture.isRawData = true;
        this._needRender = false;
    }
}

// Future TODO: 3D Text Component (text to mesh)
