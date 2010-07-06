varying vec2 TX;
varying vec3 N;
varying vec3 V;
varying vec3 T;

const vec3 EyeDir   = vec3(0.0, 0.0, 1.0);

uniform sampler2D tex0;

uniform float shininess;
uniform float specularScale;

vec3 peturbNormal(in vec3 normal, in vec3 tangent, in vec2 texCoords);
vec2 peturbTexCoords(in vec3 normal, in vec3 tangent, in vec2 texCoords);
vec3 calculateDiffuseLight(in vec3 normal);
vec3 calculateSpecularLight(in vec3 normal, in float exponent);

vec3 lightDirection(in vec3 vertex);
vec3 lightColour(in vec3 vertex);

vec3 postprocessColour(in vec3 colour, in vec3 normal);

void main()
{
	vec3 normal = normalize(N);
	vec3 tangent = normalize(T);
	normal = peturbNormal(normal, T, TX);
	vec2 texCoord = peturbTexCoords(normal, T, TX);
	vec4 sample = texture2D(tex0, texCoord);
	vec3 light = calculateDiffuseLight(normal);
	light += sample.a * specularScale * calculateSpecularLight(normal, shininess);
	gl_FragColor = vec4(postprocessColour(light * sample.rgb, normal), 1.0);
}
