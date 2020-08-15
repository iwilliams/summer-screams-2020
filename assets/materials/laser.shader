shader_type spatial;

//render_mode unshaded;
render_mode unshaded, cull_disabled, skip_vertex_transform;

uniform sampler2D albedoTex : hint_albedo;
uniform sampler2D alphaTex : hint_albedo;
uniform vec2 duv = vec2(1, 0);
uniform float alphaMax = 1.;
uniform float alphaMin = .2;
const float snapRes = 50.0;

void vertex() {
    UV.x = UV.x + (1. * duv.x) * TIME;
    UV.y = UV.y + (1. * duv.y) * TIME;
    VERTEX = (MODELVIEW_MATRIX * vec4(VERTEX, 1.0)).xyz;
	VERTEX.xyz = floor(VERTEX.xyz * snapRes) / snapRes;
}

void fragment() {
    ALBEDO = vec3(COLOR[0], COLOR[1], COLOR[2]);
    ALBEDO *= texture(albedoTex, UV).rgb;
    ALPHA = mix(alphaMin, alphaMax, texture(alphaTex, UV).r);
}