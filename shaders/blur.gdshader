shader_type canvas_item;

uniform float blur_amount : hint_range(0.0, 5.0) = 2.0;
// Use hint_screen_texture to grab what's behind the object
uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap, repeat_enable;

void fragment() {
    // textureLod uses the mipmaps to simulate blur
    // Note: blur_amount must be greater than 0 to see a difference
    vec4 color = textureLod(screen_texture, SCREEN_UV, blur_amount);
    COLOR = color;
}