# Derp Project

## Subprojects

* [Derp](#derp) is the library.
* [Derper](#derper) is the loader (runtime) for fully scripted applications.
* [HerpDerp](#herpderp) is the editor.

---
<a name="derp">
# Derp - Engine

Derp is a very simple and yet to be powerful game engine for 2D and 3D games written in D. It is supposed to be a *hybrid engine*, providing both a D and a Lua interface. Thus it will be possible to write application code both in D (compiled) or Luad (scripted, dynamically loaded and executed).

## Goals

It is planned that derp features

- 2D and 3D Graphics via [OpenGL](http://www.opengl.org/)
- audio via [OpenAL](http://openal.org/)
- simple, extensible resource loading, with many already supported types ([ASSIMP](http://assimp.sourceforge.net/))
- simple distribution (see also [Derper](#derper))
- powerful scene graph with entity/component system
- full scene serialization (level files etc.)
- full access to engine API from LUA
- *and probably more*

---
<a name="derper">
# Derper - Loader

**Derper** is a simple to use loader for fully scripted derp applications. Similar to the distribution method of [Löve2D](http://love2d.org) packages, derper will be able to open a package containing all application data. This should make it very easy to distribute (open-source) projects for all supported platforms.

---
<a name="herpderp">
# HerpDerp - Editor

**HerpDerp** is a planned scene graph editor for the derp engine. This subproject has not yet been started.
