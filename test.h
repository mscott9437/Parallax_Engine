#pragma once

#include <stdio.h>
#include <sqlite3.h>
#include <GLFW/glfw3.h>

#define INPUT_LENGTH 1
#define LINE_LENGTH 16384

#define WIDTH 800
#define HEIGHT 600

static int callback(void*, int, char**, char**);

void framebuffer_size_callback(GLFWwindow*, int, int);
void processInput(GLFWwindow*);

const char *vertexShaderSource = "#version 330 core\n"
	"layout (location = 0) in vec3 aPos;\n"
	"void main()\n"
	"{\n"
	"   gl_Position = vec4(aPos.x, aPos.y, aPos.z, 1.0);\n"
	"}\0";

const char *fragmentShaderSource = "#version 330 core\n"
	"out vec4 FragColor;\n"
	"void main()\n"
	"{\n"
	"   FragColor = vec4(1.0f, 0.5f, 0.2f, 1.0f);\n"
	"}\n\0";

#define GL_VERTEX_SHADER 0x8B31
#define GL_FRAGMENT_SHADER 0x8B30
#define GL_ARRAY_BUFFER 0x8892
#define GL_STATIC_DRAW 0x88E4
#define GL_ELEMENT_ARRAY_BUFFER 0x8893

typedef char GLchar;
typedef signed long long int GLsizeiptr;
typedef GLuint (*GL_CREATESHADER) (GLenum);
typedef void (*GL_SHADERSOURCE) (GLuint, GLsizei, const GLchar**, const GLint*);
typedef void (*GL_COMPILESHADER) (GLuint);
typedef GLuint (*GL_CREATEPROGRAM) (void);
typedef void (*GL_ATTACHSHADER) (GLuint, GLuint);
typedef void (*GL_LINKPROGRAM) (GLuint);
typedef void (*GL_USEPROGRAM) (GLuint);
typedef void (*GL_DELETESHADER) (GLuint);
typedef void (*GL_GENBUFFERS) (GLsizei, GLuint*);
typedef void (*GL_GENVERTEXARRAYS) (GLsizei, GLuint*);
typedef void (*GL_BINDVERTEXARRAY) (GLuint);
typedef void (*GL_BINDBUFFER) (GLenum, GLuint);
typedef void (*GL_BUFFERDATA) (GLenum, GLsizeiptr, const void*, GLenum);
typedef void (*GL_VERTEXATTRIBPOINTER) (GLuint, GLint, GLenum, GLboolean, GLsizei, const void*);
typedef void (*GL_ENABLEVERTEXATTRIBARRAY) (GLuint);
typedef void (*GL_DELETEVERTEXARRAYS) (GLsizei, const GLuint*);
typedef void (*GL_DELETEBUFFERS) (GLsizei, const GLuint*);
typedef void (*GL_DELETEPROGRAM) (GLuint);
