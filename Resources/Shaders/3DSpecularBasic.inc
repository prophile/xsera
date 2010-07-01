vec3 calculateSpecularLight(in vec3 normal, in float exponent)
{
	vec3 LightDir = lightDirection(V);
	vec3 LightCol = lightColour(V);
	vec3 HalfDir  = normalize(LightDir + EyeDir);
	float NdL = dot(normal, LightDir);
	if (NdL > 0.0)
	{
		float NdHV = max(dot(normal, HalfDir), 0.0);
		float powf = pow(NdHV, exponent);
		return LightCol * powf;
	}
	else
	{
		return vec3(0.0);
	}
}
