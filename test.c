#include "test.h"

int main(void)
{
	sqlite3 *db;
	char *zErrMsg = 0;
	int rc = sqlite3_open("db/test.db", &db);
	char *sql;

	FILE *fp = fopen("ss/init.sql" , "r");
	char line[LINE_LENGTH];

	while (fgets(line, LINE_LENGTH, fp) != NULL) rc = sqlite3_exec(db, line, NULL, NULL, NULL);

	char str[INPUT_LENGTH + 3];
	char i;

	char b = 1;

	while (b == 1) {
		fgets(str, sizeof(str), stdin);
		i = 0;

		while (str[i] != '\0') {
			if (i > INPUT_LENGTH) {
				puts("error: StreamTooLong");
				//return 1;
				b = 0;
			}

			i++;
		}

		printf("%s", str);
	}

	sql = "select * from users;";
	rc = sqlite3_exec(db, sql, callback, 0, &zErrMsg);

	sqlite3_close(db);

	glfwInit();
	GLFWwindow *window = glfwCreateWindow(WIDTH, HEIGHT, "Parallax Engine", NULL, NULL);
	glfwMakeContextCurrent(window);

	GL_CREATESHADER glCreateShader  = (GL_CREATESHADER)glfwGetProcAddress("glCreateShader");
	GL_SHADERSOURCE glShaderSource  = (GL_SHADERSOURCE)glfwGetProcAddress("glShaderSource");
	GL_COMPILESHADER glCompileShader  = (GL_COMPILESHADER)glfwGetProcAddress("glCompileShader");
	GL_CREATEPROGRAM glCreateProgram  = (GL_CREATEPROGRAM)glfwGetProcAddress("glCreateProgram");
	GL_ATTACHSHADER glAttachShader  = (GL_ATTACHSHADER)glfwGetProcAddress("glAttachShader");
	GL_LINKPROGRAM glLinkProgram  = (GL_LINKPROGRAM)glfwGetProcAddress("glLinkProgram");
	GL_USEPROGRAM glUseProgram  = (GL_USEPROGRAM)glfwGetProcAddress("glUseProgram");
	GL_DELETESHADER glDeleteShader  = (GL_DELETESHADER)glfwGetProcAddress("glDeleteShader");
	GL_GENBUFFERS glGenBuffers  = (GL_GENBUFFERS)glfwGetProcAddress("glGenBuffers");
	GL_GENVERTEXARRAYS glGenVertexArrays  = (GL_GENVERTEXARRAYS)glfwGetProcAddress("glGenVertexArrays");
	GL_BINDVERTEXARRAY glBindVertexArray  = (GL_BINDVERTEXARRAY)glfwGetProcAddress("glBindVertexArray");
	GL_BINDBUFFER glBindBuffer  = (GL_BINDBUFFER)glfwGetProcAddress("glBindBuffer");
	GL_BUFFERDATA glBufferData  = (GL_BUFFERDATA)glfwGetProcAddress("glBufferData");
	GL_VERTEXATTRIBPOINTER glVertexAttribPointer  = (GL_VERTEXATTRIBPOINTER)glfwGetProcAddress("glVertexAttribPointer");
	GL_ENABLEVERTEXATTRIBARRAY glEnableVertexAttribArray  = (GL_ENABLEVERTEXATTRIBARRAY)glfwGetProcAddress("glEnableVertexAttribArray");
	GL_DELETEVERTEXARRAYS glDeleteVertexArrays  = (GL_DELETEVERTEXARRAYS)glfwGetProcAddress("glDeleteVertexArrays");
	GL_DELETEBUFFERS glDeleteBuffers  = (GL_DELETEBUFFERS)glfwGetProcAddress("glDeleteBuffers");
	GL_DELETEPROGRAM glDeleteProgram  = (GL_DELETEPROGRAM)glfwGetProcAddress("glDeleteProgram");

	glfwSetFramebufferSizeCallback(window, framebuffer_size_callback);

	unsigned int vertexShader = glCreateShader(GL_VERTEX_SHADER);

	glShaderSource(vertexShader, 1, &vertexShaderSource, NULL);
	glCompileShader(vertexShader);

	unsigned int fragmentShader = glCreateShader(GL_FRAGMENT_SHADER);

	glShaderSource(fragmentShader, 1, &fragmentShaderSource, NULL);
	glCompileShader(fragmentShader);

	unsigned int shaderProgram = glCreateProgram();

	glAttachShader(shaderProgram, vertexShader);
	glAttachShader(shaderProgram, fragmentShader);
	glLinkProgram(shaderProgram);

	glDeleteShader(vertexShader);
	glDeleteShader(fragmentShader);  
/*
	float vertices[] = {
		-0.5f, -0.5f, 0.0f,
		0.5f, -0.5f, 0.0f,
		0.0f,  0.5f, 0.0f
	};
*/
	float vertices[] = {
		0.5f,  0.5f, 0.0f,
		0.5f, -0.5f, 0.0f,
		-0.5f, -0.5f, 0.0f,
		-0.5f,  0.5f, 0.0f
	};

	unsigned int indices[] = {
		0, 1, 3,
		1, 2, 3
	};

	unsigned int VBO, VAO, EBO;
	glGenVertexArrays(1, &VAO);  
	glGenBuffers(1, &VBO);
	glGenBuffers(1, &EBO);

	glBindVertexArray(VAO);

	glBindBuffer(GL_ARRAY_BUFFER, VBO);
	glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);

	glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, EBO);
	glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(indices), indices, GL_STATIC_DRAW);

	glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 3 * sizeof(float), (void*)0);
	glEnableVertexAttribArray(0);  

	glBindBuffer(GL_ARRAY_BUFFER, 0); 
	//glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);

	glBindVertexArray(0); 

	glPolygonMode(GL_FRONT_AND_BACK, GL_LINE);

	while (!glfwWindowShouldClose(window)) {
		processInput(window);

		glClearColor(0.2f, 0.3f, 0.3f, 1.0f);
		glClear(GL_COLOR_BUFFER_BIT);

		glUseProgram(shaderProgram);
		glBindVertexArray(VAO);
		//glDrawArrays(GL_TRIANGLES, 0, 3);
		//glDrawArrays(GL_TRIANGLES, 0, 6);
		glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_INT, 0);
		//glBindVertexArray(0);

		glfwSwapBuffers(window);
		glfwPollEvents();
	}

	glDeleteVertexArrays(1, &VAO);
	glDeleteBuffers(1, &VBO);
	glDeleteBuffers(1, &EBO);
	glDeleteProgram(shaderProgram);

	glfwTerminate();

	return 0;
}

static int callback(void *NotUsed, int argc, char **argv, char **azColName)
{
	int i;
	for(i = 0; i<argc; i++) printf("%s = %s\n", azColName[i], argv[i] ? argv[i] : "NULL");
	printf("\n");
	return 0;
}

void framebuffer_size_callback(GLFWwindow *window, int width, int height)
{
	glViewport(0, 0, WIDTH, HEIGHT);
}

void processInput(GLFWwindow *window)
{
	if(glfwGetKey(window, GLFW_KEY_ESCAPE) == GLFW_PRESS) glfwSetWindowShouldClose(window, GLFW_TRUE);
}
