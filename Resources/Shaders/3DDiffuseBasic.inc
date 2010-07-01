vec3 calculateDiffuseLight(in vec3 normal)
{
	float NdL = dot(normal, LightDir);
	return LightCol * max(0.0, NdL);
}
