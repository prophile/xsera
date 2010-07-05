vec3 calculateDiffuseLight(in vec3 normal)
{
	vec3 LightDir = lightDirection(V);
	vec3 LightCol = lightColour(V);
	float NdL = dot(normal, LightDir);
	return LightCol * max(0.0, NdL);
}
