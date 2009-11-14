varying vec2 tx;
uniform sampler2D texture;

void main ()
{
	vec4 starColour = texture2D(texture, tx);
	if (starColour.a < 0.1)
		discard;
	gl_FragColor = starColour;
}

