shader_type canvas_item;

bool between(float coord, float minimum, float maximum) {
	return coord >= minimum && coord <= maximum;
}

float loc_x(float loc) {
	return loc / 256.0;
}

float loc_y(float loc) {
	return loc / 64.0;
}

void fragment() {
	COLOR = texture(TEXTURE, UV);
	if (
		COLOR == vec4(0.0, 0.0, 0.0, 1.0) 
		&& !(between(UV.y, loc_y(20.0),loc_y(24.0))
		&& (between(UV.x, loc_x(48.0), loc_x(52.0)) 
		|| between(UV.x, loc_x(112.0), loc_x(120.0)) 
		|| between(UV.x, loc_x(176.0), loc_x(180.0)) 
		|| between(UV.x, loc_x(244.0), loc_x(248.0)))) ) {
		
		COLOR.b = 0.25;
		COLOR.r = 0.25;
		COLOR.g = 0.25;
	}


}
