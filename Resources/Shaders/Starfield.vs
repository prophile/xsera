varying vec2 tx;

void main ()
{
	tx = gl_MultiTexCoord0.st;
	gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex;
}

