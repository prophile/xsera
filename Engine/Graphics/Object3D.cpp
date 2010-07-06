#include "Object3D.h"
#include "Matrix2x3.h"
#include "Utilities/ResourceManager.h"
#include "ImageLoader.h"
#include "Shaders.h"

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
	vector3 () : x(0.0f), y(0.0f), z(0.0f) {}

	vector3 operator-(const vector3& v3) const
	{
		return vector3(x - v3.x, y - v3.y, z - v3.z);
	}

	vector3 operator-() const
	{
		return vector3() - *this;
	}

	bool operator==(const vector3& ov3) const
	{
		return x == ov3.x &&
		       y == ov3.y &&
			   z == ov3.z;
	}
};

inline vector3 cross(vector3 a, vector3 b)
{
	vector3 result(0.0f, 0.0f, 0.0f);
	result.x = a.y*b.z - a.z*b.y;
	result.y = a.z*b.x - a.x*b.z;
	result.z = a.x*b.y - a.y*b.x;
	return result;
}

inline vector3 unit(vector3 a)
{
	float mag = sqrtf(a.x*a.x + a.y*a.y + a.z*a.z);
	if (mag < 0.001)
		return vector3(0.0, 0.0, 1.0);
	a.x /= mag;
	a.y /= mag;
	a.z /= mag;
	return a;
}

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
	return ImageLoader::CreateTexture(surface, true, false);
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
	if (string.empty())
		return 0;
	return atoi(string.c_str());
}

struct faceTriple
{
	int vertices[3];
	int texes[3];
	int norms[3];
};

}

void Object3D::LoadObject ( const std::string& name )
{
	assert(sizeof(vector2) == 2*sizeof(float));
	assert(sizeof(vector3) == 3*sizeof(float));
	std::vector<vector3> fileVertices, faceVertices;
	std::vector<vector2> fileTexCoords, faceTexCoords;
	std::vector<vector3> fileNormals, faceNormals;
	std::vector<vector3> faceTangents;
	std::vector<faceTriple> faceTriples;
	bool normalGen = true;
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
		else if (type == "vt")
		{
			float x = StringToFloat(PopWord(line));
			float y = StringToFloat(PopWord(line));
			fileTexCoords.push_back(vector2(x, y));
		}
		else if (type == "vn")
		{
			float x = StringToFloat(PopWord(line));
			float y = StringToFloat(PopWord(line));
			float z = StringToFloat(PopWord(line));
			fileNormals.push_back(vector3(x, y, z));
			normalGen = false;
		}
		else if (type == "f" || type == "fo")
		{
			std::string lines[4];
			lines[0] = PopWord(line);
			lines[1] = PopWord(line);
			lines[2] = PopWord(line);
			lines[3] = PopWord(line);
			unsigned int vertices[4];
			unsigned int texes[4];
			unsigned int norms[4];
			bool quad = lines[3] != "";
			vertices[0] = StringToInt(PopWord(lines[0], '/'));
			vertices[1] = StringToInt(PopWord(lines[1], '/'));
			vertices[2] = StringToInt(PopWord(lines[2], '/'));
			if (quad)
				vertices[3] = StringToInt(PopWord(lines[3], '/'));
			texes[0] = StringToInt(PopWord(lines[0], '/'));
			texes[1] = StringToInt(PopWord(lines[1], '/'));
			texes[2] = StringToInt(PopWord(lines[2], '/'));
			if (quad)
				texes[3] = StringToInt(PopWord(lines[3], '/'));
			norms[0] = StringToInt(PopWord(lines[0], '/'));
			norms[1] = StringToInt(PopWord(lines[1], '/'));
			norms[2] = StringToInt(PopWord(lines[2], '/'));
			if (quad)
				norms[3] = StringToInt(PopWord(lines[3], '/'));
			faceTriple triple;
			triple.vertices[0] = vertices[0];
			triple.vertices[1] = vertices[1];
			triple.vertices[2] = vertices[2];
			triple.texes[0] = texes[0];
			triple.texes[1] = texes[1];
			triple.texes[2] = texes[2];
			triple.norms[0] = norms[0];
			triple.norms[1] = norms[1];
			triple.norms[2] = norms[2];
			faceTriples.push_back(triple);
			if (quad)
			{
				triple.vertices[1] = vertices[2];
				triple.vertices[2] = vertices[3];
				triple.texes[1] = texes[2];
				triple.texes[2] = texes[3];
				triple.norms[1] = norms[2];
				triple.norms[2] = norms[3];
				faceTriples.push_back(triple);
			}
		}
	}
	for (std::vector<faceTriple>::iterator iter = faceTriples.begin();
										   iter != faceTriples.end();
										   ++iter)
	{
		unsigned int vtx, tex, norm;
		float u[3];
		vector3 vertices[3];
		vtx  = iter->vertices[0] - 1;
		tex  = iter->texes[0] ? iter->texes[0] - 1 : iter->vertices[0] - 1;
		norm = iter->norms[0] - 1;
		vertices[0] = fileVertices[vtx];
		u[0] = fileTexCoords[tex].x;
		faceVertices.push_back(fileVertices[vtx]);
		faceTexCoords.push_back(fileTexCoords[tex]);
		if (!normalGen)
			faceNormals.push_back(fileNormals[norm]);
		vtx  = iter->vertices[1] - 1;
		tex  = iter->texes[1] ? iter->texes[1] - 1 : iter->vertices[1] - 1;
		norm = iter->norms[1] - 1;
		vertices[1] = fileVertices[vtx];
		u[1] = fileTexCoords[tex].x;
		faceVertices.push_back(fileVertices[vtx]);
		faceTexCoords.push_back(fileTexCoords[tex]);
		if (!normalGen)
			faceNormals.push_back(fileNormals[norm]);
		vtx  = iter->vertices[2] - 1;
		tex  = iter->texes[2] ? iter->texes[2] - 1 : iter->vertices[2] - 1;
		norm = iter->norms[2] - 1;
		vertices[2] = fileVertices[vtx];
		u[2] = fileTexCoords[tex].x;
		faceVertices.push_back(fileVertices[vtx]);
		faceTexCoords.push_back(fileTexCoords[tex]);
		if (!normalGen)
			faceNormals.push_back(fileNormals[norm]);
		// generate normals and tangents
		assert(!(vertices[1] == vertices[0]));
		assert(!(vertices[2] == vertices[0]));
		assert(!(vertices[2] == vertices[1]));
		vector3 AB = vertices[1] - vertices[0];
		vector3 AC = vertices[2] - vertices[0];
		vector3 normal = unit(cross(AB, AC));
		vector3 tangent;
		if (u[0] >= u[1] && u[1] >= u[2])
			tangent = AB;
		else if (u[0] < u[1] && u[1] < u[2])
			tangent = -AB;
		else if (u[0] >= u[1] && u[1] < u[2])
			tangent = AC;
		else if (u[0] < u[1] && u[1] >= u[2])
			tangent = -AC;
		tangent = unit(tangent);
		if (normalGen)
		{
			faceNormals.push_back(normal);
			faceNormals.push_back(normal);
			faceNormals.push_back(normal);
		}
		faceTangents.push_back(tangent);
		faceTangents.push_back(tangent);
		faceTangents.push_back(tangent);
	}
	GLuint bufs[4];
	glGenBuffers(4, bufs);
	vertexVBO  = bufs[0];
	texVBO     = bufs[1];
	normalsVBO = bufs[2];
	tangentVBO = bufs[3];
	nverts = faceVertices.size();
	//printf("Read %d vertices = %d triangles\n", nverts, nverts / 3);
	assert(faceVertices.size() == faceNormals.size());
	assert(faceVertices.size() == faceTexCoords.size());
	assert(faceVertices.size() == faceTangents.size());
	vector3* vtxPtr  = (vector3*)&(faceVertices.front());
	vector3* normPtr = (vector3*)&(faceNormals.front());
	vector2* texPtr  = (vector2*)&(faceTexCoords.front());
	vector3* tgtPtr  = (vector3*)&(faceTangents.front());
	glBindBuffer(GL_ARRAY_BUFFER, vertexVBO);
	glBufferData(GL_ARRAY_BUFFER, nverts * sizeof(vector3), vtxPtr, GL_STATIC_DRAW);
	glBindBuffer(GL_ARRAY_BUFFER, normalsVBO);
	glBufferData(GL_ARRAY_BUFFER, nverts * sizeof(vector3), normPtr, GL_STATIC_DRAW);
	glBindBuffer(GL_ARRAY_BUFFER, texVBO);
	glBufferData(GL_ARRAY_BUFFER, nverts * sizeof(vector2), texPtr, GL_STATIC_DRAW);
	glBindBuffer(GL_ARRAY_BUFFER, tangentVBO);
	glBufferData(GL_ARRAY_BUFFER, nverts * sizeof(vector3), tgtPtr, GL_STATIC_DRAW);
	glBindBuffer(GL_ARRAY_BUFFER, 0);
	SDL_RWclose(objFile);
}

void Object3D::LoadTexture(const std::string& name)
{
	SDL_Surface* diffuse = ImageLoader::LoadImage("Textures/" + name + "_diffuse.png");
	assert(diffuse);
	SDL_Surface* specular = ImageLoader::LoadImage("Textures/" + name + "_spec.png");
	//assert(specular); // if it fails to load, it's fine - zip'll fill it in
	SDL_Surface* res = ImageLoader::Zip(diffuse, specular);
	assert(res);
	SDL_FreeSurface(specular);
	SDL_FreeSurface(diffuse);
	texture = ImageLoader::CreateTexture(res, true, false, true);
	assert(texture);
}

Object3D::Object3D ( const std::string& name )
: offX(-0.5f), offY(-0.5f), intScale(1.0f), shininess(11.0f), specScale(1.2f)
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
	glDeleteBuffers(1, &tangentVBO);
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
	glEnable(GL_DEPTH_TEST);
	//glEnable(GL_CULL_FACE);
	glDepthMask(GL_TRUE);
	glPushMatrix();
	glEnableClientState(GL_NORMAL_ARRAY);
	glEnableVertexAttribArray(1);
	glRotatef(bank, 0.0f, 1.0f, 0.0f);
	glScalef(intScale, intScale, intScale);
	glTranslatef(offX, offY, 0.0f);
	//glRotatef(90.0f, 1.0f, 0.0f, 0.0f);
	// bind the VBOs
	glBindBuffer(GL_ARRAY_BUFFER, vertexVBO);
	glVertexPointer(3, GL_FLOAT, 0, NULL);
	glBindBuffer(GL_ARRAY_BUFFER, normalsVBO);
	glNormalPointer(GL_FLOAT, 0, NULL);
	glBindBuffer(GL_ARRAY_BUFFER, texVBO);
	glTexCoordPointer(2, GL_FLOAT, 0, NULL);
	Shaders::BindAttribute(1, "Tangent");
	glBindBuffer(GL_ARRAY_BUFFER, tangentVBO);
	glVertexAttribPointer(1, 3, GL_FLOAT, GL_FALSE, 0, NULL);
	// draw all the faces
	glBindBuffer(GL_ARRAY_BUFFER, 0);
	glDrawArrays(GL_TRIANGLES, 0, nverts);
	glDisableVertexAttribArray(1);
	glDisableClientState(GL_NORMAL_ARRAY);
	glPopMatrix();
	glDepthMask(GL_FALSE);
	glDisable(GL_DEPTH_TEST);
	glDisable(GL_CULL_FACE);
}

}
