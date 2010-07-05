const float ATT_CONST = 0.6;
const float ATT_LINEAR = 0.2;
const float ATT_QUAD = 0.08;

uniform vec3 lightPosition;
uniform vec3 lightColour;
uniform float lightIntensity;

float attenuation(in vec3 vertex)
{
	vec3 aux = lightPosition - vertex;
	float distance = length(aux);
	return 1.0 / (ATT_CONST + ATT_LINEAR*distance + ATT_QUAD*distance*distance);
}

vec3 lightDirection(in vec3 vertex)
{
	return normalize(lightPosition - vertex);
}

vec3 lightColour(in vec3 vertex)
{
	return lightColour * lightIntensity * attenuation(vertex);
}
