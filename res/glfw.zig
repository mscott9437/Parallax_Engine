#define CGLM_ALL_UNALIGNED
#include <cglm/cglm.h>

//#define STB_IMAGE_IMPLEMENTATION
//#include "stb_image.h"

#include <ft2build.h>
#include FT_FREETYPE_H
//#include FT_GLYPH_H

#include <glad/glad.h>
#include <GLFW/glfw3.h>

#define WIDTH 800
#define HEIGHT 600

#define GL_CLAMP_TO_EDGE 0x812F 

void framebuffer_size_callback(GLFWwindow*, int, int); 
void processInput(GLFWwindow*);

void RenderText(unsigned int, char[], float, float, float, vec3);

const char *vs = "#version 330 core\n"
	"layout (location = 0) in vec4 vertex;\n"// <vec2 pos, vec2 tex>
	"out vec2 TexCoords;\n"
	"uniform mat4 projection;\n"
	"void main()\n"
	"{\n"
	"	gl_Position = projection * vec4(vertex.xy, 0.0, 1.0);\n"
	"	TexCoords = vertex.zw;\n"
	"}\0";

const char *fs = "#version 330 core\n"
	"in vec2 TexCoords;\n"
	"out vec4 color;\n"
	"uniform sampler2D text;\n"
	"uniform vec3 textColor;\n"
	"void main()\n"
	"{\n"
	"	vec4 sampled = vec4(1.0, 1.0, 1.0, texture(text, TexCoords).r);\n"
	"	color = vec4(textColor, 1.0) * sampled;\n"
	"}\0";

//const char *gs = "";

struct Character {
	unsigned int TextureID;// ID handle of the glyph texture
	int SizeX;// Size of glyph
	int SizeY;
	int BearingX;// Offset from baseline to left/top of glyph
	int BearingY;
	unsigned int Advance;// Horizontal offset to advance to next glyph
};

unsigned int VBO, VAO;
//unsigned int VBO, VAO, EBO;

struct Character character;

int main(int argc, char *argv[]) {// char **argv

	glfwInit();
	glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 3);
	glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 3);
	glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE);
	//glfwWindowHint(GLFW_OPENGL_FORWARD_COMPAT, GL_TRUE);// MacOS

	GLFWwindow *window = glfwCreateWindow(WIDTH, HEIGHT, "Parallax Engine", NULL, NULL);
	glfwMakeContextCurrent(window);
	glfwSetFramebufferSizeCallback(window, framebuffer_size_callback);  
	gladLoadGLLoader((GLADloadproc)glfwGetProcAddress);

	glEnable(GL_CULL_FACE);
	glEnable(GL_BLEND);
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

	unsigned int vertex = glCreateShader(GL_VERTEX_SHADER);
	glShaderSource(vertex, 1, &vs, NULL);
	glCompileShader(vertex);

	unsigned int fragment = glCreateShader(GL_FRAGMENT_SHADER);
	glShaderSource(fragment, 1, &fs, NULL);
	glCompileShader(fragment);
/*
	unsigned int geometry = glCreateShader(GL_GEOMETRY_SHADER);
	glShaderSource(geometry, 1, &gs, NULL);
	glCompileShader(geometry);
*/
	unsigned int ID = glCreateProgram();

	glAttachShader(ID, vertex);
	glAttachShader(ID, fragment);
	//glAttachShader(ID, geometry);

	glLinkProgram(ID);

	glDeleteShader(vertex);
	glDeleteShader(fragment);
	//glDeleteShader(geometry);

	mat4 projection;
	glm_ortho(0.0f, 800.0f, 0.0f, 600.0f, -1.0f, 1.0f, projection);
	glUseProgram(ID);
	glUniformMatrix4fv(glGetUniformLocation(ID, "projection"), 1, GL_FALSE, *projection);

	FT_Library ft;
	FT_Face face;

	FT_Init_FreeType(&ft);
	FT_New_Face(ft, "db/CascadiaMono.ttf", 0, &face);

	FT_Set_Pixel_Sizes(face, 0, 48);
	glPixelStorei(GL_UNPACK_ALIGNMENT, 1);

	unsigned char c = 64;

	FT_Load_Char(face, c, FT_LOAD_RENDER);
	
	unsigned int texture;

	glGenTextures(1, &texture);
	glBindTexture(GL_TEXTURE_2D, texture);
	glTexImage2D(
		GL_TEXTURE_2D,
		0,
		GL_RED,
		face->glyph->bitmap.width,
		face->glyph->bitmap.rows,
		0,
		GL_RED,
		GL_UNSIGNED_BYTE,
		face->glyph->bitmap.buffer
	);

	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);

	character.TextureID = texture,
	character.SizeX = face->glyph->bitmap.width;
	character.SizeY = face->glyph->bitmap.rows;
	character.BearingX = face->glyph->bitmap_left;
	character.BearingY = face->glyph->bitmap_top;
	character.Advance = face->glyph->advance.x;

	glBindTexture(GL_TEXTURE_2D, 0);

	FT_Done_Face (face);
	FT_Done_FreeType(ft);

	glGenVertexArrays(1, &VAO);
	glGenBuffers(1, &VBO);
	//glGenBuffers(1, &EBO);

	glBindVertexArray(VAO);
	glBindBuffer(GL_ARRAY_BUFFER, VBO);

	//glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);
	glBufferData(GL_ARRAY_BUFFER, sizeof(float) * 6 * 4, NULL, GL_DYNAMIC_DRAW);

	//glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, EBO);
	//glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(indices), indices, GL_STATIC_DRAW);

	glEnableVertexAttribArray(0);
	glVertexAttribPointer(0, 4, GL_FLOAT, GL_FALSE, 4 * sizeof(float), 0);

	glBindBuffer(GL_ARRAY_BUFFER, 0); 
	glBindVertexArray(0); 

	while (!glfwWindowShouldClose(window))
	{
		processInput(window);

		glClearColor(0.2f, 0.3f, 0.3f, 1.0f);
		glClear(GL_COLOR_BUFFER_BIT);

		RenderText(ID, "@", 25.0f, 25.0f, 1.0f, (vec3){0.5, 0.8f, 0.2f});
		RenderText(ID, "@", 540.0f, 570.0f, 0.5f, (vec3){0.3, 0.7f, 0.9f});

		glfwSwapBuffers(window);
		glfwPollEvents();
	}

	//glDeleteVertexArrays(1, &VAO);
	//glDeleteBuffers(1, &VBO);
	//glDeleteBuffers(1, &EBO);
	//glDeleteProgram(ID);

	glfwTerminate();

	return 0;

}

void framebuffer_size_callback(GLFWwindow* window, int width, int height)
{
	glViewport(0, 0, WIDTH, HEIGHT);
}

void processInput(GLFWwindow* window)
{
	if(glfwGetKey(window, GLFW_KEY_ESCAPE) == GLFW_PRESS)
		glfwSetWindowShouldClose(window, GLFW_TRUE);
}

void RenderText(unsigned int shader, char text[], float x, float y, float scale, vec3 color)
{
	glUseProgram(shader);
	glUniform3f(glGetUniformLocation(shader, "textColor"), color[0], color[1], color[2]);
	glActiveTexture(GL_TEXTURE0);
	glBindVertexArray(VAO);

	struct Character ch = character;

	float xpos = x + ch.BearingX * scale;
	float ypos = y - (ch.SizeY - ch.BearingY) * scale;

	float w = ch.SizeX * scale;
	float h = ch.SizeY * scale;

	float vertices[6][4] = {
		{xpos, ypos + h, 0.0f, 0.0f},
		{xpos, ypos, 0.0f, 1.0f},
		{xpos + w, ypos, 1.0f, 1.0f},

		{xpos, ypos + h, 0.0f, 0.0f},
		{xpos + w, ypos, 1.0f, 1.0f},
		{xpos + w, ypos + h, 1.0f, 0.0f}
	};

	glBindTexture(GL_TEXTURE_2D, ch.TextureID);

	glBindBuffer(GL_ARRAY_BUFFER, VBO);
	glBufferSubData(GL_ARRAY_BUFFER, 0, sizeof(vertices), vertices); // be sure to use glBufferSubData and not glBufferData

	glBindBuffer(GL_ARRAY_BUFFER, 0);
	glDrawArrays(GL_TRIANGLES, 0, 6);

	x += (ch.Advance >> 6) * scale; // bitshift by 6 to get value in pixels (2^6 = 64 (divide amount of 1/64th pixels by 64 to get amount of pixels))

	glBindVertexArray(0);
	glBindTexture(GL_TEXTURE_2D, 0);
}
