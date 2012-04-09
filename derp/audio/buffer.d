module derp.audio.buffer;

import std.math;
import std.stdio;

import derelict.openal.al;

import derp.audio.util;
import derp.audio.source;

alias short SampleType;

class SoundBuffer {
    alias float function(float src, float time) SampleModifier;

    float[] data;
    uint handle;
    uint samplingRate;

    @property float duration() {
        return 1.0 * data.length / samplingRate;
    }

    this(float duration = 0, uint samplingRate = 44000) {
        this.samplingRate = samplingRate;
        create(duration);
    }

    delete(void* buffer) {
        (cast(SoundBuffer)buffer).destroy();
    }

    void create(float duration = 0) {
        alGenBuffers(1, &handle);
        alCheck();

        generate(duration);
    }

    void destroy() {
        foreach(sourceHandle; queuedSources)
            alSourceUnqueueBuffers(sourceHandle, 1, &handle);

        alDeleteBuffers(1, &handle);
        alCheck();
    }

    void generate(float duration = 0) {
        uint length = cast(uint)ceil(duration * samplingRate);
        data = new float[length];
        for(int f = 0; f < length; ++f)
            data[f] = 0;
    }

    void fill(SampleModifier modifier, float wet = 1.0) {
        for(int f = 0; f < data.length; ++f) {
            float new_v = modifier(1, 1.0 * f / samplingRate);
            data[f] = wet * new_v + (1 - wet) * data[f];
            assert(-1 <= data[f] && data[f] <= 1);
        }
    }

    void modify(SampleModifier modifier, float wet = 1.0) {
        for(int f = 0; f < data.length; ++f) {
            float new_v = modifier(data[f], 1.0 * f / samplingRate);
            data[f] = wet * new_v + (1 - wet) * data[f];
            assert(-1 <= data[f] && data[f] <= 1);
        }
    }

    void sendData() {
        SampleType[] buffer = new SampleType[data.length];
        for(int f = 0; f < data.length; ++f) {
            buffer[f] = cast(SampleType) map(data[f], -1, 1,
                    SampleType.min, SampleType.max);
        }
        alBufferData(handle, AL_FORMAT_MONO16, &buffer[0],
                cast(int)(buffer.length * SampleType.sizeof), samplingRate);
        alCheck();
    }

    uint[] queuedSources;

    void queueInto(SoundSource source) {
        queuedSources ~= source.handle;
        alSourceQueueBuffers(source.handle, 1, &handle);
        alCheck();
    }
}
