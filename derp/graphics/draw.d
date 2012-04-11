/**
 * Draws simple shapes.
 */

module derp.graphics.draw;

import std.stdio;
import std.string;

struct Color {
    static Color Black          = Color(0, 0, 0);
    static Color DarkGray       = Color(0.2, 0.2, 0.2);
    static Color Gray           = Color(0.5, 0.5, 0.5);
    static Color White          = Color(1, 1, 1);
    static Color Transparent    = Color(0, 0, 0, 0);
    static Color Red            = Color(1, 0, 0);
    static Color Green          = Color(0, 1, 0);
    static Color Blue           = Color(0, 0, 1);
    static Color Yellow         = Color(1, 1, 0);
    static Color Cyan           = Color(0, 1, 1);
    static Color Magenta        = Color(1, 0, 1);

    static Color Background     = Color(0.055, 0.2235, 0.4);

    float r, g, b, a;

    this(float r, float g, float b, float a = 1) {
        this.r = r;
        this.g = g;
        this.b = b;
        this.a = a;
    }
}
