#include "Shaders.h"
#ifdef WIN32
//note to Windows users: you must install GLEW for this to work (and put it in the same directory as your GL headers):
//http://glew.sourceforge.net/
#include <gl/glew.h>
#else
#include <OpenGL/gl.h>
#endif
#include "Apollo.h"
#include "Utilities/ResourceManager.h"
#include <map>
#include <assert.h>

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
	if (!len)
		return;
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
	if (!len)
		return;
	fwrite(logBuffer, len, 1, stdout);
	putchar('\n');
}

static void ParseIncludes ( std::string& shader )
{
	std::string::size_type pos;
	while ((pos = shader.find("#pragma import ")) != std::string::npos)
	{
		size_t len;
		pos += strlen("#pragma import ");
		std::string::size_type endPos = shader.find_first_of('\n', pos);
		std::string fileName = shader.substr(pos, endPos - pos);
		SDL_RWops* rwops = ResourceManager::OpenFile("Shaders/" + fileName + ".inc");
		char* buffer = (char*)ResourceManager::ReadFull(&len, rwops, 1);
		std::string include ( buffer, len );
		free(buffer);
		pos -= strlen("#pragma import ");
		shader.replace(pos, endPos - pos, include);
	}
}

class Shader
{
private:
	GLuint vertexObject, fragmentObject, programObject;
public:
	Shader ( std::string vertexProgram, std::string fragmentProgram )
	{
		// preprocess
		ParseIncludes(vertexProgram);
		ParseIncludes(fragmentProgram);

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
		PrintLogProgram(programObject);
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
			// bind textures
			for (int i = 0; i < 4; ++i)
			{
				char name[6];
				sprintf(name, "tex%d", i);
				GLint pos = glGetUniformLocation(programObject, name);
				if (pos != -1)
					glUniform1i(pos, i);
			}
		}
	}
};

typedef std::map<std::string, Shader*> ShaderMap;
static ShaderMap shaders;

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
		SDL_RWops* vertexOps = ResourceManager::OpenFile("Shaders/" + name + ".vs");
		SDL_RWops* fragmentOps = ResourceManager::OpenFile("Shaders/" + name + ".fs");
		assert(vertexOps);
		assert(fragmentOps);
		size_t len;
		char* buffer = (char*)ResourceManager::ReadFull(&len, vertexOps, 1);
		std::string vertex ( buffer, len );
		free(buffer);
		buffer = (char*)ResourceManager::ReadFull(&len, fragmentOps, 1);
		std::string fragment ( buffer, len );
		free(buffer);
		AddShader(name, vertex, fragment);
		// call self
		SetShader(name);
	}
}

GLuint UniformLocation ( const std::string& name )
{
	GLuint location = glGetUniformLocation(currentShader, name.c_str());
	assert(location != -1UL);
	return location;
}

}

}
