#version 330 core
// in vec3 out_color;
in vec2 out_uv;

uniform sampler2D tex;

out vec4 frag_color;

void main() {
    frag_color = texture(tex, out_uv);
}
