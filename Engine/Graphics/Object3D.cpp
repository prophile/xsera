#include "Object3D.h"
#include "Matrix2x3.h"
#include "Utilities/ResourceManager.h"
#include "ImageLoader.h"

namespace Graphics
{

namespace Matrices
{

void SetProjectionMatrix ( const matrix2x3& m );
void SetViewMatrix ( const matrix2x3& m );
void SetModelMatrix ( const matrix2x3& m );

const matrix2x3& CurrentMatrix ();
const matrix2x3& ProjectionMatrix ();
const matrix2x3& ViewMatrix ();
const matrix2x3& ModelMatrix ();

}

namespace
{

struct vector3
{
	float x, y, z;
	vector3 ( float _x, float _y, float _z ) : x(_x), y(_y), z(_z) {}
};

struct vector2
{
	float x, y;
	vector2 ( float _x, float _y ) : x(_x), y(_y) {}
};

GLuint GetTexture ( const std::string& path )
{
	SDL_Surface* surface = ImageLoader::LoadImage(path);
	if (!surface)
		return NULL;
	return ImageLoader::CreateTexture(surface, true);
}

void StripComments ( std::string& line )
{
	std::string::size_type index;
	index = line.find_first_of('#');
	if (index != std::string::npos)
	{
		line.erase(index);
	}
	// check for trailing whitespace
	while (line.length() > 0 && line[line.length() - 1] == ' ')
	{
		line.erase(line.length() - 1);
	}
}

bool ReadLine ( SDL_RWops* ops, std::string& line )
{
	char inputCharacter;
	line.assign("");
	while (SDL_RWread(ops, &inputCharacter, 1, 1) > 0)
	{
		if (inputCharacter == '\r')
		{
			// discard \r
			continue;
		}
		if (inputCharacter == '\n')
		{
			StripComments(line);
			if (line == "") // if it's a dead line, recurse to get the next line
				return ReadLine(ops, line);
			return true;
		}
		line.push_back(inputCharacter);
	}
	StripComments(line);
	return line.length() > 0;
}

std::string PopWord ( std::string& string, char separator = ' ' )
{
	std::string::size_type pos = string.find_first_of(separator);
	if (pos == std::string::npos)
	{
		// take the entire string
		std::string copy(string);
		string.assign("");
		return copy;
	}
	else
	{
		// get the first string
		std::string copy(string.substr(0, pos));
		string = string.substr(pos + 1);
		return copy;
	}
}

float StringToFloat ( const std::string& string )
{
	return atof(string.c_str());
}

unsigned int StringToInt ( const std::string& string )
{
	return atoi(string.c_str());
}

}

void Object3D::LoadObject ( const std::string& name )
{
	std::vector<vector3> fileVertices, faceVertices;
	std::vector<vector3> fileNormals, faceNormals;
	std::vector<vector2> fileTexCoords, faceTexCoords;
	SDL_RWops* objFile = ResourceManager::OpenFile("Objects/" + name + ".obj");
	assert(objFile);
	// fill vertices, tex coords, and faces
	std::string line;
	while (ReadLine(objFile, line))
	{
		std::string type = PopWord(line);
		if (type == "v")
		{
			float x = StringToFloat(PopWord(line));
			float y = StringToFloat(PopWord(line));
			float z = StringToFloat(PopWord(line));
			fileVertices.push_back(vector3(x, y, z));
		}
		else if (type == "vn")
		{
			float x = StringToFloat(PopWord(line));
			float y = StringToFloat(PopWord(line));
			float z = StringToFloat(PopWord(line));
			fileNormals.push_back(vector3(x, y, z));
		}
		else if (type == "vt")
		{
			float x = StringToFloat(PopWord(line));
			float y = StringToFloat(PopWord(line));
			fileTexCoords.push_back(vector2(x, y));
		}
		else if (type == "f")
		{
			std::string firstVertex  = PopWord(line);
			std::string secondVertex = PopWord(line);
			std::string thirdVertex  = PopWord(line);
			unsigned int vtx, tex, norm;
			vtx  = StringToInt(PopWord(firstVertex, '/'));
			tex  = StringToInt(PopWord(firstVertex, '/'));
			norm = StringToInt(PopWord(firstVertex, '/'));
			faceVertices.push_back(fileVertices[vtx]);
			faceTexCoords.push_back(fileTexCoords[tex]);
			faceNormals.push_back(fileNormals[norm]);
			vtx  = StringToInt(PopWord(secondVertex, '/'));
			tex  = StringToInt(PopWord(secondVertex, '/'));
			norm = StringToInt(PopWord(secondVertex, '/'));
			faceVertices.push_back(fileVertices[vtx]);
			faceTexCoords.push_back(fileTexCoords[tex]);
			faceNormals.push_back(fileNormals[norm]);
			vtx  = StringToInt(PopWord(thirdVertex, '/'));
			tex  = StringToInt(PopWord(thirdVertex, '/'));
			norm = StringToInt(PopWord(thirdVertex, '/'));
			faceVertices.push_back(fileVertices[vtx]);
			faceTexCoords.push_back(fileTexCoords[tex]);
			faceNormals.push_back(fileNormals[norm]);
		}
	}
	glGenBuffers(1, &vertexVBO);
	glGenBuffers(1, &texVBO);
	glGenBuffers(1, &normalsVBO);
	glBindBuffer(GL_ARRAY_BUFFER, vertexVBO);
	glBufferData(GL_ARRAY_BUFFER, faceVertices.size() * sizeof(vector3), &(faceVertices.front()), GL_STATIC_DRAW);
	glBindBuffer(GL_ARRAY_BUFFER, normalsVBO);
	glBufferData(GL_ARRAY_BUFFER, faceNormals.size() * sizeof(vector3), &(faceNormals.front()), GL_STATIC_DRAW);
	glBindBuffer(GL_ARRAY_BUFFER, texVBO);
	glBufferData(GL_ARRAY_BUFFER, faceTexCoords.size() * sizeof(vector2), &(faceTexCoords.front()), GL_STATIC_DRAW);
	glBindBuffer(GL_ARRAY_BUFFER, 0);
	nverts = faceVertices.size();
	SDL_RWclose(objFile);
}

void Object3D::LoadTexture ( const std::string& name )
{
	texture = GetTexture("Textures/" + name + "_diffuse.png");
	assert(texture);
}

Object3D::Object3D ( const std::string& name )
{
	// load the texture
	LoadTexture(name);
	LoadObject(name);
}

Object3D::~Object3D ()
{
	glDeleteTextures(1, &texture);
	glDeleteBuffers(1, &vertexVBO);
	glDeleteBuffers(1, &texVBO);
	glDeleteBuffers(1, &normalsVBO);
}

void Object3D::BindTextures ()
{
	glBindTexture(GL_TEXTURE_2D, texture);
}

void Object3D::Draw ( float scale, float angle, float bank )
{
	// set up matrices
	matrix2x3 transformation;
	transformation *= matrix2x3::Scale(scale);
	transformation *= matrix2x3::Rotation(angle);
	Matrices::SetModelMatrix(transformation);
	glPushMatrix(GL_MODELVIEW_MATRIX);
	glRotatef(bank, 1.0f, 0.0f, 0.0f);
	// bind the VBOs
	glBindBuffer(GL_ARRAY_BUFFER, vertexVBO);
	glVertexPointer(3, GL_FLOAT, 0, NULL);
	glBindBuffer(GL_ARRAY_BUFFER, normalsVBO);
	glNormalPointer(GL_FLOAT, 0, NULL);
	glBindBuffer(GL_ARRAY_BUFFER, texVBO);
	glTexCoordPointer(2, GL_FLOAT, 0, NULL);
	// draw all the faces
	glDrawArrays(GL_TRIANGLES, 0, nverts);
	glBindBuffer(GL_ARRAY_BUFFER, 0);
	glPopMatrix();
}

}
