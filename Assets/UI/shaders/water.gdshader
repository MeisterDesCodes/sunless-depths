shader_type canvas_item;

uniform sampler2D screen_texture: hint_screen_texture; 
uniform sampler2D noise_texture: filter_nearest, repeat_enable;

uniform vec2 speed = vec2(2, 0.5);
uniform float distortion = 0.005;

void vertex() {
	//VERTEX.y += sin(TIME);
}

void fragment() {
	vec2 uv = UV * speed * TIME;
	vec2 noise = 2.0 * texture(noise_texture, uv).rg - vec2(1.0);
	COLOR = texture(TEXTURE, UV);
	COLOR += texture(screen_texture, SCREEN_UV + noise * distortion);
} 