const vec3 LightDir = vec3(0.71, 0.71, 0.3);
const vec3 LightCol = vec3( 0.95,  0.80, 0.6);

vec3 lightDirection(in vec3 vertex)
{
	return LightDir;
}

vec3 lightColour(in vec3 vertex)
{
	return LightCol;
}
