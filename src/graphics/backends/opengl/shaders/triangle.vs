#version 330 core
layout(location = 0) in vec3 pos;

out vec3 color;

void main() {
    gl_Position = vec4(pos.x, pos.y, pos.z, 1.0);
    if (gl_VertexID == 0) {
        color = vec3(1,0,0);
    } else if (gl_VertexID == 1) {
        color = vec3(0,1,0);
    } else {
        color = vec3(0,0,1);
    }
}
