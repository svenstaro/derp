/**
 * Draws simple shapes.
 */

module derp.graphics.draw;

import std.stdio;
import std.string;
import derp.math.all;

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

    float r, g, b, a = 1.0;

    this(float r, float g, float b, float a = 1) {
        this.r = r;
        this.g = g;
        this.b = b;
        this.a = a;
    }

    @property float min() {
        return fmin(fmin(this.r, this.g), this.b);
    }

    @property float max()  {
        return fmax(fmax(this.r, this.g), this.b);
    }

    @property float hue() {
        float d = this.max - this.min;

        if (d == 0)
            return 0;
        else if (this.r == this.max && (this.g - this.b) > 0)
            return 60 * (this.g - this.b) / d;
        else if (this.r == this.max && (this.g - this.b) <= 0)
            return (60 * (this.g - this.b) / d + 360) % 360;
        else if (this.g == this.max)
            return 60 * (this.b - this.r) / d + 120;
        else if (this.b == this.max)
            return 60 * (this.r - this.g) / d + 240;
        return 0f;
    }

    @property float saturation() {
        return max - min;
    }

    alias max value; // for Hue/Saturation/Value
}
