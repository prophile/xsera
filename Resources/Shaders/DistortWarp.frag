varying vec2 V;
varying vec2 TX;
uniform vec2 Target;
uniform float Angle;
uniform float Magnitude;

uniform sampler2DRect sampler;

const float TEXELDIST = 20.0;
const float MAGFACTOR = 5.0;
const float CONSTANTDIST = -1.0;
const float DISTEXPONENT = 0.3;

const float PI = 3.14159265;
const float TWOPI  = PI * 2.0;
const float HALFPI = PI * 0.5;

float atan2 ( float y, float x )
{
	if (y + x == y)
	{
		return HALFPI * sign(y);
	}
	float angle = atan(y/x);
	if (x < 0.0)
	{
		return angle + (PI * -sign(angle));
	}
	return angle;
}

float calculateShortAngleDifference ( float angle1, float angle2 )
{
	float diff = abs(angle1 - angle2);
	diff = mod(diff, TWOPI);
	if (diff > PI)
		diff = TWOPI - diff;
	return abs(diff);
}

void main ()
{
	float dist = length(V - Target);
	float actualAngle = atan2((V.y - Target.y), (V.x - Target.x));
	float angleDifference = calculateShortAngleDifference(actualAngle, Angle);
	float editedDistance = pow(1.0 / dist, DISTEXPONENT) + CONSTANTDIST;
	float negativeOffset = clamp(editedDistance * (angleDifference / HALFPI), 0.0, 1.0);
	float positiveOffset = clamp(editedDistance * 1.0-(angleDifference / HALFPI), 0.0, 1.0);
	float totalOffset = (negativeOffset - positiveOffset) * Magnitude * MAGFACTOR;
	float texelOffsetX = cos(actualAngle) * totalOffset * TEXELDIST;
	float texelOffsetY = sin(actualAngle) * totalOffset * TEXELDIST;
	vec2 tx = TX + vec2(texelOffsetX, texelOffsetY);
	gl_FragColor = texture2DRect(sampler, tx);
}
