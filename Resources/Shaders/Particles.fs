varying vec2 TX;
uniform sampler2D sampler;
uniform float Alpha;

void main ()
{
	//vec4 sample = texture2D(sampler, TX);
	//sample.a *= Alpha;
	//gl_FragColor = sample;
	gl_FragColor = vec4(1.0, 1.0, 1.0, Alpha);
}
