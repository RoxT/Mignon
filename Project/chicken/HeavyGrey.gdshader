shader_type canvas_item;

uniform float saturation : hint_range(0.0, 10.0) = 100.0;

void fragment() {
    vec4 tex_color = texture(TEXTURE, UV);
	if (COLOR.rgb == vec3(0.0, 0.0, 0.0)){
		COLOR.rgb = vec3(0.5, 0.5, 0.5)
	} else {
    	COLOR.rgb = mix(vec3(dot(tex_color.rgb, vec3(0.299, 0.587, 0.114))), tex_color.rgb, saturation);
	}
	COLOR.a = tex_color.a;
}