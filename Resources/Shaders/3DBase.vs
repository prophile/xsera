varying vec3 N;
varying vec2 TX;

void main()
{
	TX = gl_MultiTexCoord0.st;
	N = normalize(gl_NormalMatrix * gl_Normal);
	gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex;
}
