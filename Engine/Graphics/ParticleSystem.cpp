#include "ParticleSystem.h"
#include "GameTime.h"
#include "ImageLoader.h"
#include "RNG.h"
#include "Shaders.h"
#include <assert.h>

namespace Graphics
{

std::map<std::string, GLuint> particles;

GLuint GetParticleTexture ( const std::string& name )
{
	std::map<std::string, GLuint>::iterator iter = particles.find(name);
	if (iter == particles.end())
	{
		SDL_Surface* sfc = ImageLoader::LoadImage("Particles/" + name + ".png");
		assert(sfc);
		GLuint texture = ImageLoader::CreateTexture(sfc, true, false);
		particles.insert(std::make_pair(name, texture));
		return texture;
	}
	else
	{
		return iter->second;
	}
}

static RNG particleRNG (17);

ParticleSystem::ParticleSystem ( const std::string& name, unsigned long pcount, float sf, vec2 centre, vec2 averageVelocity, vec2 velocityVariance, vec2 accel, float lifetime )
: count(pcount), acceleration(accel), sizeFactor(sf)
{
	size = vec2(6.0f, 6.0f);
	baseTime = GameTime();
	lastTime = baseTime;
	expireTime = baseTime + lifetime;
	velocity = new vec2[pcount];
	position = new vec2[pcount];
	for (unsigned long i = 0; i < pcount; i++)
	{
		position[i] = centre;
		velocity[i].X() = averageVelocity.X() + particleRNG.RandomFloat(-velocityVariance.X(), velocityVariance.X());
		velocity[i].Y() = averageVelocity.Y() + particleRNG.RandomFloat(-velocityVariance.Y(), velocityVariance.Y());
	}
	texID = GetParticleTexture(name);
}

void ParticleSystem::Draw ()
{
	float delta = (lastTime - baseTime) / (expireTime - baseTime);
	vec2 targetSize = size * sizeFactor;
	vec2 halfParticleSize = ((targetSize*delta) + (size*(1.0f-delta))) * 0.25f;
	vec2 halfParticleYI = vec2(halfParticleSize.X(), -halfParticleSize.Y());
	glBindTexture(GL_TEXTURE_2D, texID);
	assert(texID);
	vec2 particles[count*4];
	vec2 texCoords[count*4];
#ifndef NDEBUG
	printf("Delta = %f\nHS = %f, %f\n", delta, halfParticleSize.X(), halfParticleSize.Y());
#endif
	for (unsigned long i = 0; i < count; i++)
	{
		vec2 pos = position[i];
		particles[(i*4)+0] = pos - halfParticleSize;
		particles[(i*4)+1] = pos - halfParticleYI;
		particles[(i*4)+2] = pos + halfParticleSize;
		particles[(i*4)+3] = pos + halfParticleYI;
		texCoords[(i*4)+0] = vec2(0.0f, 0.0f);
		texCoords[(i*4)+1] = vec2(0.0f, 1.0f);
		texCoords[(i*4)+2] = vec2(1.0f, 1.0f);
		texCoords[(i*4)+3] = vec2(1.0f, 0.0f);
	}
	glFlush();
	glUniform1f(Shaders::UniformLocation("Alpha"), 1.0f-delta);
	glVertexPointer(2, GL_FLOAT, 0, particles);
	glTexCoordPointer(2, GL_FLOAT, 0, texCoords);
	glDrawArrays(GL_QUADS, 0, count*4);
}

bool ParticleSystem::Update ()
{
	float time = GameTime();
	float dt = time - baseTime;
	if (time > expireTime)
		return true;
	for (unsigned long i = 0; i < count; i++)
	{
		velocity[i] += acceleration * dt;
		position[i] += velocity[i] * dt;
	}
	lastTime = time;
	return false;
}

}
