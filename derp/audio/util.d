module derp.audio.util;

import std.string;
import std.stdio;

import derelict.openal.al;

static void* globalAudioDevice, globalAudioContext;

void initializeAudio() {
    DerelictAL.load();

    void* globalAudioDevice = alcOpenDevice(null);
    void* globalAudioContext = alcCreateContext(globalAudioDevice, null);
    alcMakeContextCurrent(globalAudioContext);
}

void deinitializeAudio() {
    alcDestroyContext(globalAudioContext);
    alcCloseDevice(globalAudioDevice);
}



float map(float src, float fS, float fE, float tS, float tE)
in {
    assert(src >= fS && src <= fE);
}
out (r) {
    assert(r >= tS && r <= tE);
}
body {
    return tS + (src - fS) / (fE - fS) * (tE - tS);
}

bool alCheck(string file = __FILE__, int line = __LINE__) {
    int error = alGetError();
    if(error == AL_NO_ERROR) return true;

    string msg = format("Unknown error code (%s).", error);

    switch(error) {
        case AL_INVALID_NAME:
            msg = "Invalid name.";
            break;
        case AL_INVALID_ENUM:
            msg = "Invalid enum parameter.";
            break;
        case AL_INVALID_VALUE:
            msg = "Invalid value.";
            break;
        case AL_INVALID_OPERATION:
            msg = "Invalid operation.";
            break;
        case AL_OUT_OF_MEMORY:
            msg = "Out of memory.";
            break;
        default:
            break;
    }

    writefln("AL Error in [%s:%s] %s", file, line, msg);
    return false;
}
