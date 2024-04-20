shader_type canvas_item;

render_mode blend_mix;

uniform sampler2D node_texture;
uniform sampler2D SCREEN_TEXTURE: hint_screen_texture;
uniform float distortionStrength = 0.3;

void fragment() {
	vec2 distoredUV = SCREEN_UV + texture(node_texture, UV).r * distortionStrength;
	vec4 screenColor = texture(SCREEN_TEXTURE, distoredUV);
	
	COLOR = screenColor;
}

void light() {
	// Called for every pixel for every light affecting the CanvasItem.
}
