shader_type canvas_item;

const int UINT8_MAX = 255;
const int POW_2_8 = 256;
const int POW_2_16 = 65536;

uniform vec2 offset;

// IFDEF EXPLICIT_INDEX_TEXTURE
uniform sampler2D index_texture;
// ENDIF
uniform sampler2D palette_texture: hint_white;
uniform sampler2D offset_texture: hint_black;

void fragment() {
	vec2 palette_size = vec2(textureSize(palette_texture, 0));
	vec2 palette_fwidth = 1.0 / palette_size;
	
	vec4 indexed_color;
	// IFDEF EXPLICIT_INDEX_TEXTURE
	indexed_color = texture(index_texture, UV);
	// ELSE
	indexed_color = texture(TEXTURE, UV);
	// ENDIF
	ivec4 integer_color = ivec4(indexed_color * float(POW_2_8));
	int palette_index = (
		integer_color.x +
		integer_color.y * POW_2_8 +
		integer_color.z * POW_2_16
	);
	
	int palette_idx = palette_index;
	
	vec2 palette_uv = vec2(float(palette_idx) / palette_size.x, 0.0) + (offset * palette_fwidth) + (palette_fwidth * 0.5);
	vec2 offset_uv = texture(offset_texture, palette_uv).rg * palette_fwidth;
	
	// IFDEF VISUALIZE_INDICES
	COLOR = vec4(vec3(float(palette_index) / (palette_size.x - 1.0)), indexed_color.a);
	// ELSE	
	COLOR = vec4(texture(palette_texture, palette_uv + offset_uv).xyz, indexed_color.a);
	// ENDIF
}