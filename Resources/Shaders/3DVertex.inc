varying vec2 TX;
varying vec3 N;
varying vec3 V;

void main()
{
	vec4 worldPosition = gl_ModelViewMatrix * gl_Vertex;
	V = worldPosition.xyz;
	TX = gl_MultiTexCoord0.st;
	N = gl_NormalMatrix * gl_Normal;
	gl_Position = gl_ProjectionMatrix * worldPosition;
}
