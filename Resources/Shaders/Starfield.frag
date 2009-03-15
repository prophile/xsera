varying vec2 tx;
uniform sampler2D texture;

void main ()
{
	gl_FragColor = texture2D(texture, tx);
//	gl_FragColor = vec4(1.0, 0.0, 0.0, 1.0);
//	gl_FragColor = vec4(fract(tx.x), fract(tx.y), 0.0, 1.0);
}

