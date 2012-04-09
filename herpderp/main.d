import derp.all;

import std.stdio;

import derelict.opengl3.gl3;
import derelict.glfw3.glfw3;

int main(string[] args) {
    audioTest();
    return 0;

    Window w = new Window("Hello World", 300, 200, 32, Window.Mode.Windowed);

    for(int i = 0; i < 100; ++i) {
        w.update();
        w.clear(new Color(1, 0, 0));
        w.display();
    }
    w.close();

    /*DerelictGL3.load();
    DerelictGLFW3.load();

    if(!glfwInit()) {
        writeln("Cannot make init");
        return 1;
    }

    //glfwOpenWindowHint(GLFW_OPENGL_VERSION_MAJOR, 2);
    //glfwOpenWindowHint(GLFW_OPENGL_VERSION_MINOR, 1);
    //glfwOpenWindowHint(GLFW_OPENGL_FORWARD_COMPAT, GL_TRUE);

    GLFWwindow w = glfwOpenWindow(100, 100, GLFW_WINDOWED, "omg", null);
    if(w) {
        writeln("Made a window.");
    } else {
        writeln("Failed making a window.");
    }
    DerelictGL3.reload();

    glfwTerminate();*/
    return 0;
}
