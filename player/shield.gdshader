shader_type canvas_item;

render_mode blend_add;

uniform sampler2D noise_texture: repeat_enable;
uniform float shieldValue;
uniform float elapsed = 0.0f;

uniform float shieldRadius = 0.18f;
uniform float intensity = 0.8f;
uniform float layers = 10.0f;
uniform float speed = 10.0f;

float gradient(vec2 uv) {
	float radius = clamp(shieldRadius,0.18,0.23) - distance(vec2(0.5,0.5), vec2(uv.x, uv.y));
	return radius;
}

vec4 colorize(float c, float a) {
	vec4 palette;
	palette = vec4(0.0,c/1.3,c,a);
	return palette;
}

void fragment() {
	vec4 textureColor = texture(noise_texture, UV - elapsed / speed);
	COLOR.r = gradient(UV);
	float clampedIntensity = clamp(intensity, 0.8f, 10.0f);
	COLOR.r = clamp(COLOR.r * textureColor.r * clampedIntensity * 10.0f, 0.0f, 1.0f);
	COLOR.r = floor(COLOR.r * layers) / layers;
	COLOR.a = float(COLOR.r > 0.0f);
	COLOR = colorize(COLOR.r, COLOR.a);
	COLOR = vec4(COLOR.r, COLOR.g, COLOR.b, COLOR.a * (shieldValue));
}

void light() {
	// Called for every pixel for every light affecting the CanvasItem.
}
