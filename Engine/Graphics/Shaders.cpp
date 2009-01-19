#include "Shaders.h"
#include <OpenGL/gl.h>
#include "Utilities/ResourceManager.h"
#include <map>

namespace Graphics
{

namespace Shaders
{

GLuint currentShader = 0;

static void PrintLogProgram ( GLuint object )
{
	GLint status;
	glGetProgramiv(object, GL_LINK_STATUS, &status);
	if (status == GL_TRUE)
		return;
	char logBuffer[1024];
	GLsizei len;
	glGetProgramInfoLog(object, sizeof(logBuffer), &len, logBuffer);
	fwrite(logBuffer, len, 1, stdout);
	putchar('\n');
}

static void PrintLogShader ( GLuint object )
{
	GLint status;
	glGetShaderiv(object, GL_COMPILE_STATUS, &status);
	if (status == GL_TRUE)
		return;
	char logBuffer[1024];
	GLsizei len;
	glGetShaderInfoLog(object, sizeof(logBuffer), &len, logBuffer);
	fwrite(logBuffer, len, 1, stdout);
	putchar('\n');
}

class Shader
{
private:
	GLuint vertexObject, fragmentObject, programObject;
public:
	Shader ( std::string vertexProgram, std::string fragmentProgram )
	{
		// compile the vertex shader
		const char* source = vertexProgram.data();
		GLint len = vertexProgram.length();
		vertexObject = glCreateShader(GL_VERTEX_SHADER);
		glShaderSource(vertexObject, 1, &source, &len);
		glCompileShader(vertexObject);
		PrintLogShader(vertexObject);
		
		// compile the fragment shader
		source = fragmentProgram.data();
		len = fragmentProgram.length();
		fragmentObject = glCreateShader(GL_FRAGMENT_SHADER);
		glShaderSource(fragmentObject, 1, &source, &len);
		glCompileShader(fragmentObject);
		PrintLogShader(fragmentObject);
		
		// link the program
		programObject = glCreateProgram();
		glAttachShader(programObject, vertexObject);
		glAttachShader(programObject, fragmentObject);
		glLinkProgram(programObject);
		PrintLogProgram(vertexObject);
	}
	
	~Shader ()
	{
		glDeleteShader(vertexObject);
		glDeleteShader(fragmentObject);
		glDeleteProgram(programObject);
	}
	
	void Bind ()
	{
		if (currentShader != programObject)
		{
			currentShader = programObject;
			glUseProgram(programObject);
		}
	}
};

typedef std::map<std::string, Shader*> ShaderMap;
ShaderMap shaders;

void AddShader ( const std::string& name, const std::string& vertex, const std::string& fragment )
{
	Shader* newShader = new Shader ( vertex, fragment );
	shaders[name] = newShader;
}

void SetShader ( const std::string& name )
{
	ShaderMap::iterator iter = shaders.find(name);
	if (iter != shaders.end())
	{
		iter->second->Bind();
	}
	else
	{
		// add the shader
		SDL_RWops* vertexOps = ResourceManager::OpenFile("Shaders/" + name + ".vtx");
		SDL_RWops* fragmentOps = ResourceManager::OpenFile("Shaders/" + name + ".frag");
		assert(vertexOps);
		assert(fragmentOps);
		size_t len;
		char* buffer = (char*)ResourceManager::ReadFull(&len, vertexOps, 1);
		std::string vertex ( buffer, len );
		buffer = (char*)ResourceManager::ReadFull(&len, fragmentOps, 1);
		std::string fragment ( buffer, len );
		AddShader(name, vertex, fragment);
		// call self
		SetShader(name);
	}
}

}

}