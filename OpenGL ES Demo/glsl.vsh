#version 300 es
layout(location = 0) in vec4 vPosition;
layout(location = 1) in vec4 vColor;
uniform float offsetLoc;
out vec4 v_color;

void main()
{
    v_color = vColor;
    gl_Position = vec4(vPosition.x + offsetLoc, vPosition.yzw);
}
