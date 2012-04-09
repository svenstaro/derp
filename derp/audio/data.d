module derp.audio.data;

import derelict.openal.al;

import std.math;
import std.stdio;
import std.random;
import std.file;

import derp.audio.buffer;
import derp.audio.source;
import derp.audio.util;

float fadeIn(float duration)(float src, float time) {
    float fac = 1;
    if(duration > 0 && time < duration) fac = time / duration;
    return src * fac;
}

float fadeOut(float duration, float length)(float src, float time) {
    float start = length - duration;
    float fac = 0;
    if(duration > 0 && time >= start) fac = (time - start) / duration;
    return src * (1 - fac);
}

float square(float frequency, float min = -1)(float src, float time)  {
    float x = sin(time * frequency * PI * 2);
    float X = (x > 0 ? 1 : -1);
    return src * map(X, -1, 1, min, 1);
}

float sine(float frequency, float min = -1)(float src, float time)  {
    return src * map(sin(time * frequency * PI * 2), -1, 1, min, 1);
}

float random(float src, float time) {
    return src * uniform(-1.0, 1.0);
}

SoundBuffer soundBufferFromFile(string filename, int samplingRate = 44000) {
    SoundBuffer buffer = new SoundBuffer(0, samplingRate);
    byte[] b = cast(byte[]) std.file.read(filename);
    buffer.data = rawBytesToSoundBuffer(b);
    return buffer;
}

float[] rawBytesToSoundBuffer(byte[] data) {
    float[] buffer;
    for(int i = 0; i < data.length; i++) {
        buffer[i] = map(data[i], byte.min, byte.max, -1.0, 1.0);
    }
    return buffer;
}


void audioTest() {
    initializeAudio();

    SoundBuffer buf = new SoundBuffer(5);
    buf.fill(&sine!440);
    buf.modify(&sine!(10,0.8));
    buf.modify(&square!(1,0));
    buf.modify(&fadeIn!2);
    buf.modify(&fadeOut!(2, 5));
    buf.modify(&random, 0.03);
    buf.sendData();

    SoundSource source = new SoundSource();
    source.queueBuffer(buf);
    source.play();

    while(source.playing) {}

    buf.destroy();
    source.destroy();

    deinitializeAudio();
}
