shader_type canvas_item;

uniform vec4 inner_color : source_color = vec4(1.0, 0.0, 0.0, 1.0); // Color at the center (red).
uniform vec4 outer_color : source_color = vec4(0.0, 0.0, 1.0, 1.0); // Color at the edges (blue).
uniform float radius : hint_range(0.0, 1.0) = 0.5; // Radius of the circle. 1.0 is the full texture size.

void fragment() {
    // Calculate the distance from the center of the texture (0.5, 0.5)
    vec2 uv_centered = UV - vec2(0.5); // Shift UV to center
    float distance = length(uv_centered); // Get the distance from the center
    
    // Use smoothstep to create a smooth transition at the edge of the circle
    float t = smoothstep(radius - 0.1, radius, distance); // Smooth edge

    // Mix the colors based on the distance from the center
    vec4 gradient_color = mix(outer_color, inner_color, t);

    // Set the final color
    COLOR = gradient_color;
}
