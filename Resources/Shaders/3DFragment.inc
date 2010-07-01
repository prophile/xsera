varying vec2 TX;
varying vec3 N;

const vec3 EyeDir   = vec3(0.0, 0.0, 1.0);

uniform sampler2D tex;

uniform float shininess;
uniform float specularScale;

vec3 peturbNormal(in vec3 normal, in vec2 texCoords);
vec2 peturbTexCoords(in vec3 normal, in vec2 texCoords);
vec3 calculateDiffuseLight(in vec3 normal);
vec3 calculateSpecularLight(in vec3 normal, in float exponent);

void main()
{
	vec3 normal = normalize(N);
	normal = peturbNormal(normal, TX);
	vec2 texCoord = peturbTexCoords(normal, TX);
	vec4 sample = texture2D(tex, texCoord);
	vec3 light = calculateDiffuseLight(normal);
	light += sample.a * specularScale * calculateSpecularLight(normal, shininess);
	gl_FragColor = vec4(light * sample.rgb, 1.0);
}
