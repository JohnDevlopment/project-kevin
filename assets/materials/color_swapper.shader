shader_type canvas_item;

uniform vec4 OldColor1 : hint_color;
uniform vec4 OldColor2 : hint_color;
uniform vec4 OldColor3 : hint_color;

uniform vec4 NewColor1 : hint_color;
uniform vec4 NewColor2 : hint_color;
uniform vec4 NewColor3 : hint_color;

void fragment() {
	vec4 texColor = texture(TEXTURE, UV);
	
	if (texColor == OldColor1) {
		COLOR.rgb = NewColor1.rgb;
	} else if (texColor == OldColor2) {
		COLOR.rgb = NewColor2.rgb;
	} else if (texColor == OldColor3) {
		COLOR.rgb = NewColor3.rgb;
	} else {
		COLOR = texColor;
	}
}