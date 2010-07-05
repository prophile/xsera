vec3 greyscale(in vec3 col)
{
	return vec3(dot(col, vec3(0.21, 0.66, 0.13)));
}

vec3 postprocessColour(in vec3 colour, in vec3 normal)
{
	float c = 1.0 - abs(normal.z);
	c = pow(c, 4.0);
	return mix(colour * 0.2, greyscale(normalize(colour)), c);
}
