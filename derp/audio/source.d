module derp.audio.source;

import derelict.openal.al;

import derp.audio.buffer;
import derp.audio.util;

class SoundSource {
    uint handle;

    this() {
        create();
    }

    delete(void* source) {
        (cast(SoundSource)source).destroy();
    }

    void create() {
        alGenSources(1, &handle);
        alCheck();
    }

    void destroy() {
        alDeleteSources(1, &handle);
        alCheck();
    }

    void queueBuffer(SoundBuffer buffer) {
        buffer.queueInto(this);
    }

    void play() {
        alSourcePlay(handle);
        alCheck();
    }

    @property bool playing() {
        int val;
        alGetSourcei(handle, AL_SOURCE_STATE, &val);
        alCheck();
        return val == AL_PLAYING;
    }
}

