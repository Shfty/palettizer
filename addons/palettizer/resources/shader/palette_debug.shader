shader_type canvas_item;

uniform sampler2D palette_texture;

void fragment() {
	vec2 palette_size = vec2(textureSize(palette_texture, 0));
	vec2 palette_fwidth = 1.0 / palette_size;
	float palette_max = palette_size.x - 1.0;
	
	float gradient = round(UV.x * palette_max);
	int palette_idx = int(gradient);
	
	vec2 palette_uv = vec2(float(palette_idx) / palette_size.x, 0.0) + (palette_fwidth * 0.5);
	float mod_time = mod(TIME, 1.0);
	if(UV.y < 0.2) {
		COLOR = vec4(vec3(gradient / palette_max), 1.0);
	}
	else if(UV.y < 0.4) {
		COLOR = texelFetch(palette_texture, ivec2(palette_idx, 0), 0);
	}
	else if(UV.y < 0.6) {
		COLOR = texture(palette_texture, palette_uv, 0.0);
	}
	else if(UV.y < 0.8) {
		COLOR = texture(palette_texture, palette_uv + vec2(mod_time, 0.0));
	}
	else {
		vec2 foo = vec2(float(palette_idx) / 7.0, 0.0);
		COLOR = texture(palette_texture, palette_uv + vec2(0.0, mod_time));
	}
}