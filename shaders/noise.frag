#include <flutter/runtime_effect.glsl>

// Uniforms 必须与 Dart 代码中的 setFloat 顺序严格对应
uniform vec2 uResolution; // index 0, 1
uniform float uTime;      // index 2
uniform float uStrength;  // index 3

// 定义输出变量
out vec4 fragColor;

void main() {
    // 获取当前像素坐标 (Flutter 提供的内置函数)
    vec2 fragCoord = FlutterFragCoord().xy;

    // 归一化坐标 (0.0 ~ 1.0)
    vec2 uv = fragCoord / uResolution;

    // 随机噪点算法 (Gold Noise)
    float noise = fract(sin(dot(uv + uTime, vec2(12.9898, 78.233))) * 43758.5453);

    // 输出最终颜色给 fragColor
    vec3 color = vec3(noise);
    fragColor = vec4(color, uStrength);
}