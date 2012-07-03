/**
 * Creates and manages windows.
 */

module derp.graphics.util;

import std.stdio;
import std.string;

import derelict.opengl3.gl3;
import derelict.glfw3.glfw3;
import derelict.freetype.ft;
import derelict.devil.il;
import derelict.devil.ilu;
import derelict.devil.ilut;

import derp.core.input;

static bool graphicsInitialized = false;

static FT_Library freetypeLibrary;

void initializeGraphics(Context context = null) {
    if(graphicsInitialized) return;

    DerelictGL3.load();
    DerelictGLFW3.load();

    if(!glfwInit())
        throw new GraphicsException("Failed to initialize GLFW.", context);

    // reloadGraphics(context);

    // load DevIL
    DerelictIL.load();

    // load FreeType
    DerelictFT.load();
    ftCheck(FT_Init_FreeType(&freetypeLibrary));
    /*writeln("Loaded FreeType Version ", 
            freetypeLibrary.version_major, ".",
            freetypeLibrary.version_minor, ".",
            freetypeLibrary.version_patch);
            */

    /*if (ilGetInteger(IL_VERSION_NUM) < IL_VERSION ||
        iluGetInteger(ILU_VERSION_NUM) < ILU_VERSION ||
        ilutGetInteger(ILUT_VERSION_NUM) < ILUT_VERSION) {
        throw new GraphicsException("Outdated DevIL version.", context);
    }*/

    ilInit();
    //iluInit();
    //ilutInit();

    // ilutRenderer(ILUT_OPENGL);

    initializeInput();

    graphicsInitialized = true;
}

void reloadGraphics(Context context) {
    // make sure the graphics system is initialized
    initializeGraphics(context);

    GLVersion glVersion = DerelictGL3.reload();
    writefln("Loaded OpenGL Version %s", glVersion);
}

void deinitializeGraphics() {
    if(!graphicsInitialized) return;
    glfwTerminate();
}


class GraphicsException : Exception {
    Context context;

    this(string text, Context context) {
        super("Error in graphics context: " ~ text);
    }
}

interface Context {
    void activate();
}

bool glCheck(string file = __FILE__, int line = __LINE__) {
    int error = glGetError();
    if (error == GL_NO_ERROR) return true;

    write(format("[[ %s:%s ]]", file, line));

    while(error != GL_NO_ERROR) {
        switch (error) {
            case GL_INVALID_ENUM:
                writeln("GL_INVALID_ENUM: an unacceptable value has been specified for an enumerated argument");
                break;
            case GL_INVALID_VALUE:
                writeln("GL_INVALID_VALUE: a numeric argument is out of range");
                break;
            case GL_INVALID_OPERATION:
                writeln("GL_INVALID_OPERATION: the specified operation is not allowed in the current state");
                break;
            case GL_OUT_OF_MEMORY:
                writeln("GL_OUT_OF_MEMORY: there is not enough memory left to execute the command");
                break;
            case GL_INVALID_FRAMEBUFFER_OPERATION:
                writeln("GL_INVALID_FRAMEBUFFER_OPERATION_EXT: the object bound to FRAMEBUFFER_BINDING_EXT is not \"framebuffer complete\"");
                break;
            default:
                writeln("Error not listed. Value: ", error);
                break;
        }
        error = glGetError();
    }
    return false;
}

bool ilCheck(string file = __FILE__, int line = __LINE__) {
    int error = ilGetError();
    if (error == IL_NO_ERROR) return true;

    write(format("[[ %s:%s ]]", file, line));

    while (error != IL_NO_ERROR) {
        writefln("%s (%s)", iluErrorString(error), error);
    }
    return false;
}

bool ftCheck(int error, string file = __FILE__, int line = __LINE__) {
    if(error) {
        string msg;

        if(error == FT_Err_Cannot_Open_Resource) msg = "Cannot Open Resource";
        else if(error == FT_Err_Unknown_File_Format) msg = "Unknown File Format";
        else if(error == FT_Err_Invalid_File_Format) msg = "Invalid File Format";
        else if(error == FT_Err_Invalid_Version) msg = "Invalid Version";
        else if(error == FT_Err_Lower_Module_Version) msg = "Lower Module Version";
        else if(error == FT_Err_Invalid_Argument) msg = "Invalid Argument";
        else if(error == FT_Err_Unimplemented_Feature) msg = "Unimplemented Feature";
        else if(error == FT_Err_Invalid_Table) msg = "Invalid Table";
        else if(error == FT_Err_Invalid_Offset) msg = "Invalid Offset";
        else if(error == FT_Err_Invalid_Glyph_Index) msg = "Invalid Glyph Index";
        else if(error == FT_Err_Invalid_Character_Code) msg = "Invalid Character Code";
        else if(error == FT_Err_Invalid_Glyph_Format) msg = "Invalid Glyph Format";
        else if(error == FT_Err_Cannot_Render_Glyph) msg = "Cannot Render Glyph";
        else if(error == FT_Err_Invalid_Outline) msg = "Invalid Outline";
        else if(error == FT_Err_Invalid_Composite) msg = "Invalid Composite";
        else if(error == FT_Err_Too_Many_Hints) msg = "Too Many Hints";
        else if(error == FT_Err_Invalid_Pixel_Size) msg = "Invalid Pixel Size";
        else if(error == FT_Err_Invalid_Handle) msg = "Invalid Handle";
        else if(error == FT_Err_Invalid_Library_Handle) msg = "Invalid Library Handle";
        else if(error == FT_Err_Invalid_Driver_Handle) msg = "Invalid Driver Handle";
        else if(error == FT_Err_Invalid_Face_Handle) msg = "Invalid Face Handle";
        else if(error == FT_Err_Invalid_Size_Handle) msg = "Invalid Size Handle";
        else if(error == FT_Err_Invalid_Slot_Handle) msg = "Invalid Slot Handle";
        else if(error == FT_Err_Invalid_CharMap_Handle) msg = "Invalid CharMap Handle";
        else if(error == FT_Err_Invalid_Cache_Handle) msg = "Invalid Cache Handle";
        else if(error == FT_Err_Invalid_Stream_Handle) msg = "Invalid Stream Handle";
        else if(error == FT_Err_Too_Many_Drivers) msg = "Too Many Drivers";
        else if(error == FT_Err_Too_Many_Extensions) msg = "Too Many Extensions";
        else if(error == FT_Err_Out_Of_Memory) msg = "Out of Memory";
        else if(error == FT_Err_Unlisted_Object) msg = "Unlisted Object";
        else if(error == FT_Err_Cannot_Open_Stream) msg = "Cannot Open Stream";
        else if(error == FT_Err_Invalid_Stream_Seek) msg = "Invalid Stream Seek";
        else if(error == FT_Err_Invalid_Stream_Skip) msg = "Invalid Stream Skip";
        else if(error == FT_Err_Invalid_Stream_Read) msg = "Invalid Stream Read";
        else if(error == FT_Err_Invalid_Stream_Operation) msg = "Invalid Stream Operation";
        else if(error == FT_Err_Invalid_Frame_Operation) msg = "Invalid Frame Operation";
        else if(error == FT_Err_Nested_Frame_Access) msg = "Nested Frame Access";
        else if(error == FT_Err_Invalid_Frame_Read) msg = "Invalid Frame Read";
        else if(error == FT_Err_Raster_Uninitialized) msg = "Raster Uninitialized";
        else if(error == FT_Err_Raster_Corrupted) msg = "Raster Corrupted";
        else if(error == FT_Err_Raster_Overflow) msg = "Raster Overflow";
        else if(error == FT_Err_Raster_Negative_Height) msg = "Raster Negative Height";
        else if(error == FT_Err_Too_Many_Caches) msg = "Too Many Caches";
        else if(error == FT_Err_Invalid_Opcode) msg = "Invalid Opcode";
        else if(error == FT_Err_Too_Few_Arguments) msg = "Too Few Arguments";
        else if(error == FT_Err_Stack_Overflow) msg = "Stack Overflow";
        else if(error == FT_Err_Code_Overflow) msg = "Code Overflow";
        else if(error == FT_Err_Bad_Argument) msg = "Bad Argument";
        else if(error == FT_Err_Divide_By_Zero) msg = "Divide By Zero";
        else if(error == FT_Err_Invalid_Reference) msg = "Invalid Reference";
        else if(error == FT_Err_Debug_OpCode) msg = "Debug OpCode";
        else if(error == FT_Err_ENDF_In_Exec_Stream) msg = "ENDF In Exec Stream";
        else if(error == FT_Err_Nested_DEFS) msg = "Nested DEFS";
        else if(error == FT_Err_Invalid_CodeRange) msg = "Invalid CodeRange";
        else if(error == FT_Err_Execution_Too_Long) msg = "Execution Too Long";
        else if(error == FT_Err_Too_Many_Function_Defs) msg = "Too Many Function Defs";
        else if(error == FT_Err_Too_Many_Instruction_Defs) msg = "Too Many Instruction Defs";
        else if(error == FT_Err_Table_Missing) msg = "Table Missing";
        else if(error == FT_Err_Horiz_Header_Missing) msg = "Horiz Header Missing";
        else if(error == FT_Err_Locations_Missing) msg = "Locations Missing";
        else if(error == FT_Err_Name_Table_Missing) msg = "Name Table Missing";
        else if(error == FT_Err_CMap_Table_Missing) msg = "CMap Table Missing";
        else if(error == FT_Err_Hmtx_Table_Missing) msg = "Hmtx Table Missing";
        else if(error == FT_Err_Post_Table_Missing) msg = "Post Table Missing";
        else if(error == FT_Err_Invalid_Horiz_Metrics) msg = "Invalid Horiz Metrics";
        else if(error == FT_Err_Invalid_CharMap_Format) msg = "Invalid CharMap Format";
        else if(error == FT_Err_Invalid_PPem) msg = "Invalid PPem";
        else if(error == FT_Err_Invalid_Vert_Metrics) msg = "Invalid Vert Metrics";
        else if(error == FT_Err_Could_Not_Find_Context) msg = "Could Not Find Context";
        else if(error == FT_Err_Invalid_Post_Table_Format) msg = "Invalid Post Table Format";
        else if(error == FT_Err_Invalid_Post_Table) msg = "Invalid Post Table";
        else if(error == FT_Err_Syntax_Error) msg = "Syntax Error";
        else if(error == FT_Err_Stack_Underflow) msg = "Stack Underflow";
        else if(error == FT_Err_Ignore) msg = "Ignore";
        else if(error == FT_Err_Missing_Startfont_Field) msg = "Missing Startfont Field";
        else if(error == FT_Err_Missing_Font_Field) msg = "Missing Font Field";
        else if(error == FT_Err_Missing_Size_Field) msg = "Missing Size Field";
        else if(error == FT_Err_Missing_Chars_Field) msg = "Missing Chars Field";
        else if(error == FT_Err_Missing_Startchar_Field) msg = "Missing Startchar Field";
        else if(error == FT_Err_Missing_Encoding_Field) msg = "Missing Encoding Field";
        else if(error == FT_Err_Missing_Bbx_Field) msg = "Missing Bbx Field";
        else msg = "Unknown Error";

        writeln(format("[[ %s:%s ]]", file, line), " Error in FreeType: ", msg);

        return false;
    }
    return true;
}


enum CullMode {
    None,
    Back,
    Front
}

enum BlendMode {
    Replace,
    Blend,
    Add,
    AddBlended,
    Mult
}

enum DepthTestMode {
    None,
    Always,
    Equal,
    Less,
    Greater,
    LessEqual,
    GreaterEqual
}

//Set Cull Mode
void setCullMode(CullMode cm) {
    final switch(cm) {
    case CullMode.Back:
        glEnable(GL_CULL_FACE);
        glCullFace(GL_BACK);
        break;
    case CullMode.Front:
        glEnable(GL_CULL_FACE);
        glCullFace(GL_FRONT);
        break;
    case CullMode.None:
        glDisable(GL_CULL_FACE);
        break;
    }
    glCheck();
}

///Set Blend Mode
void setBlendMode(BlendMode bm) {
    final switch(bm)
    {
    case BlendMode.Replace:
        glDisable(GL_BLEND);
        break;
    case BlendMode.Blend:
        glEnable(GL_BLEND);
        glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
        break;
    case BlendMode.Add:
        glEnable(GL_BLEND);
        glBlendFunc(GL_ONE, GL_ONE);
        break;
    case BlendMode.AddBlended:
        glEnable(GL_BLEND);
        glBlendFunc(GL_SRC_ALPHA, GL_ONE);
        break;
    case BlendMode.Mult:
        glEnable(GL_BLEND);
        glBlendFunc(GL_DST_COLOR, GL_ZERO);
        break;
    }
    glCheck();
}


///Set Depth Test
void setDepthTestMode(DepthTestMode dt) {
    final switch(dt)
    {
    case DepthTestMode.None:
        glDisable(GL_DEPTH_TEST);
        break;
    case DepthTestMode.Always:
        glEnable(GL_DEPTH_TEST);
        glDepthFunc(GL_ALWAYS);
        break;
    case DepthTestMode.Equal:
        glEnable(GL_DEPTH_TEST);
        glDepthFunc(GL_EQUAL);
        break;
    case DepthTestMode.Less:
        glEnable(GL_DEPTH_TEST);
        glDepthFunc(GL_LESS);
        break;
    case DepthTestMode.Greater:
        glEnable(GL_DEPTH_TEST);
        glDepthFunc(GL_GREATER);
        break;
    case DepthTestMode.LessEqual:
        glEnable(GL_DEPTH_TEST);
        glDepthFunc(GL_LEQUAL);
        break;
    case DepthTestMode.GreaterEqual:
        glEnable(GL_DEPTH_TEST);
        glDepthFunc(GL_GEQUAL);
        break;
    }
    glCheck();
}