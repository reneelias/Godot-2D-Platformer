shader_type canvas_item;

uniform float offset = 1.0;
uniform sampler2D SCREEN_TEXTURE: hint_screen_texture, filter_linear_mipmap;

void fragment(){
	vec4 green_channel = texture(SCREEN_TEXTURE, SCREEN_UV);
	vec4 red_channel = texture(SCREEN_TEXTURE, vec2(SCREEN_UV.x + (offset * SCREEN_PIXEL_SIZE.x), SCREEN_UV.y));
	vec4 blue_channel = texture(SCREEN_TEXTURE, vec2(SCREEN_UV.x - (offset * SCREEN_PIXEL_SIZE.x), SCREEN_UV.y));
	COLOR = vec4(red_channel.r, green_channel.g, blue_channel.b, 1.0);
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
