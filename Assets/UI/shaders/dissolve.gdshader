shader_type canvas_item;

// Uniforms for dissolve control
uniform float dissolve_threshold : hint_range(0.0, 1.5) = 0.5;
uniform float border_width : hint_range(0.0, 0.1) = 0.1; // Width of the border.
uniform float border_smoothness : hint_range(0.01, 0.5) = 0.5; // Smoothness of the border transition.
uniform vec4 border_color = vec4(1.0, 0.2, 0.1, 1.0); // Border color (default red).

// Noise texture for the dissolve effect
uniform sampler2D noise_texture;

void fragment() {
    // Sample the texture color.
    vec4 tex_color = texture(TEXTURE, UV);
    
    // Ignore fully transparent pixels of the texture.
    if (tex_color.a == 0.0) {
        discard;
    }

    // Sample the noise texture.
    float noise_value = texture(noise_texture, UV).r;

    // Calculate the dissolve state.
    if (noise_value < dissolve_threshold - border_width - border_smoothness) {
        discard; // Fully dissolved region.
    } else if (noise_value < dissolve_threshold) {
        // Smoothly blend the border color based on noise_value.
        float blend_factor = smoothstep(
            dissolve_threshold - border_width - border_smoothness, 
            dissolve_threshold - border_width, 
            noise_value
        );
        COLOR = mix(border_color, tex_color, blend_factor);
    } else {
        // Visible texture region.
        COLOR = tex_color;
    }
}
