varying vec2 V;
varying vec2 TX;

void main ()
{
	TX = gl_MultiTexCoord0.st;
	V = gl_Vertex.xy;
	gl_Position = vec4(V, 0.0, 1.0);
}
