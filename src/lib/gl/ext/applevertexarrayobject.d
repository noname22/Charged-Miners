// This file is generated from text files from GLEW.
// See copyright in src/lib/gl/gl.d (BSD/MIT like).
module lib.gl.ext.applevertexarrayobject;

import lib.loader;
import lib.gl.types;

bool GL_APPLE_vertex_array_object;

void loadGL_APPLE_vertex_array_object(Loader l) {
	if (!GL_APPLE_vertex_array_object)
		return;

	loadFunc!(glBindVertexArrayAPPLE)(l);
	loadFunc!(glDeleteVertexArraysAPPLE)(l);
	loadFunc!(glGenVertexArraysAPPLE)(l);
	loadFunc!(glIsVertexArrayAPPLE)(l);
}

const GL_VERTEX_ARRAY_BINDING_APPLE = 0x85B5;

extern(System):

void (*glBindVertexArrayAPPLE)(GLuint array);
void (*glDeleteVertexArraysAPPLE)(GLsizei n, GLuint *arrays);
void (*glGenVertexArraysAPPLE)(GLsizei n, GLuint *arrays);
GLboolean (*glIsVertexArrayAPPLE)(GLuint array);
