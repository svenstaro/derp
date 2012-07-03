/**
 * Manages input.
 */

module derp.core.input;

import std.stdio;
import std.utf;

import derp.math.all;
import derelict.glfw3.glfw3;

import derp.graphics.window;

static Window _currentInputWindow = null;

extern(C) void _keyCallback(void* window, int key, int action) {
    // writefln("%s key %s", (action == GLFW_PRESS ? "pressed": "released"), key);
    if(!_currentInputWindow) return;
    if(action == GLFW_PRESS)
        _currentInputWindow.keyPressed(key);
    else
        _currentInputWindow.keyReleased(key);
}

extern(C) void _characterCallback(void* window, int unicode) {
    // writefln("unicode key %s", cast(dchar)unicode);
    if(!_currentInputWindow) return;
    _currentInputWindow.unicodePressed(cast(dchar)unicode);
}

extern(C) void _mouseButtonCallback(void* window, int button, int action) {
    // writefln("%s button %s", (action == GLFW_PRESS ? "pressed": "released"), button);
    if(!_currentInputWindow) return;
    if(action == GLFW_PRESS)
        _currentInputWindow.mouseButtonPressed(button);
    else
        _currentInputWindow.mouseButtonReleased(button);
}

void initializeInput() {
    glfwSetKeyCallback(cast(GLFWkeyfun)&_keyCallback);
    glfwSetCharCallback(cast(GLFWcharfun)&_characterCallback);
    glfwSetMouseButtonCallback(cast(GLFWmousebuttonfun)&_mouseButtonCallback);

}

struct Input {
    static bool isKeyDown(int key) {
        return glfwGetKey(cast(void*)0, key) == GLFW_PRESS;
    }

    static bool isMouseButtonDown(int button) {
        return glfwGetMouseButton(cast(void*)0, button) == GLFW_PRESS;
    }

    static vec2i getMousePosition() {
        int x, y;
        glfwGetCursorPos(cast(void*)0, &x, &y);
        return vec2i(x, y);
    }

    static void setMousePosition(vec2i pos) {
        glfwSetCursorPos(cast(void*)0, pos.x, pos.y);
    }

    enum Key {
        Space = GLFW_KEY_SPACE,
        Escape = GLFW_KEY_ESC,
        F1 = GLFW_KEY_F1,
        F2 = GLFW_KEY_F2,
        F3 = GLFW_KEY_F3,
        F4 = GLFW_KEY_F4,
        F5 = GLFW_KEY_F5,
        F6 = GLFW_KEY_F6,
        F7 = GLFW_KEY_F7,
        F8 = GLFW_KEY_F8,
        F9 = GLFW_KEY_F9,
        F10 = GLFW_KEY_F10,
        F11 = GLFW_KEY_F11,
        F12 = GLFW_KEY_F12,
        Up = GLFW_KEY_UP,
        Down = GLFW_KEY_DOWN,
        Left = GLFW_KEY_LEFT,
        Right = GLFW_KEY_RIGHT,
        LShift = GLFW_KEY_LSHIFT,
        RShift = GLFW_KEY_RSHIFT,
        LCtrl = GLFW_KEY_LCTRL,
        RCtrl = GLFW_KEY_RCTRL,
        LAlt = GLFW_KEY_LALT,
        RAlt = GLFW_KEY_RALT,
        LSuper = GLFW_KEY_LSUPER,
        RSuper = GLFW_KEY_RSUPER,
        Tab = GLFW_KEY_TAB,
        Enter = GLFW_KEY_ENTER,
        Backspace = GLFW_KEY_BACKSPACE,
        Insert = GLFW_KEY_INSERT,
        Delete = GLFW_KEY_DEL,
        PageUp = GLFW_KEY_PAGEUP,
        PageDown = GLFW_KEY_PAGEDOWN,
        Home = GLFW_KEY_HOME,
        End = GLFW_KEY_END,
        NumPad0 = GLFW_KEY_KP_0,
        NumPad1 = GLFW_KEY_KP_1,
        NumPad2 = GLFW_KEY_KP_2,
        NumPad3 = GLFW_KEY_KP_3,
        NumPad4 = GLFW_KEY_KP_4,
        NumPad5 = GLFW_KEY_KP_5,
        NumPad6 = GLFW_KEY_KP_6,
        NumPad7 = GLFW_KEY_KP_7,
        NumPad8 = GLFW_KEY_KP_8,
        NumPad9 = GLFW_KEY_KP_9,
        NumPadDivide = GLFW_KEY_KP_DIVIDE,
        NumPadMultiply = GLFW_KEY_KP_MULTIPLY,
        NumPadSubtract = GLFW_KEY_KP_SUBTRACT,
        NumPadAdd = GLFW_KEY_KP_ADD,
        NumPadDecimal = GLFW_KEY_KP_DECIMAL,
        NumPadEqual = GLFW_KEY_KP_EQUAL,
        NumPadEnter = GLFW_KEY_KP_ENTER,
        NumLock = GLFW_KEY_KP_NUM_LOCK,
        CapsLock = GLFW_KEY_CAPS_LOCK,
        ScrollLock = GLFW_KEY_SCROLL_LOCK,
        Pause = GLFW_KEY_PAUSE,
        Menu = GLFW_KEY_MENU
    }
}
