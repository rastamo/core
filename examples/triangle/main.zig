const std = @import("std");
const builtin = @import("builtin");
const Io = std.Io;

// This file should only take engine as dependency.
const core = @import("core");
const glfw = @import("zglfw");
const zopengl = @import("zopengl");
const gl = zopengl.bindings;

var vao: u32 = undefined;
var vbo: u32 = undefined;
const screen: Screen = .{};

const Screen = struct {
    width: f32 = 1920,
    height: f32 = 1080,
};

pub fn main(init: std.process.Init) !void {
    const io = init.io;
    std.debug.print("{s}\n", .{"Core library"});
    // std.debug.print("{any}\n", .{std.Io.Dir.cwd()});

    // Initialize and configure -> platform/glfw.zig
    try glfw.init();
    defer glfw.terminate();
    glfw.windowHint(.context_version_major, 3);
    glfw.windowHint(.context_version_minor, 3);
    glfw.windowHint(.opengl_profile, .opengl_core_profile);
    glfw.windowHint(.samples, 8);
    if (builtin.os.tag == .macos) {
        glfw.windowHint(.opengl_forward_compat, true);
    }

    // Window creation -> platform/Window.zig
    const window = try glfw.createWindow(screen.width, screen.height, "core", glfw.getPrimaryMonitor(), null);
    defer window.destroy();
    glfw.makeContextCurrent(window);

    // Graphics -> graphics/gl.zig
    try zopengl.loadCoreProfile(@ptrCast(&glfw.getProcAddress), 3, 3);
    gl.enable(gl.MULTISAMPLE);
    gl.enable(gl.LINE_SMOOTH);
    gl.hint(gl.LINE_SMOOTH_HINT, gl.NICEST);
    // gl.polygonMode(gl.FRONT_AND_BACK, gl.LINE);

    // Graphics -> graphics/shaders/text.zig
    var shader = try core.graphics.Shader.init(io, "src/graphics/shaders/triangle.vs", "src/graphics/shaders/triangle.fs");
    defer shader.deinit();
    shader.use();

    // Configure VAO/VBO for texture quads -> graphics/gl.zig
    const vertices = [_]f32{
        -0.5, -0.5, 0,
        0,    0.5,  0,
        0.5,  -0.5, 0,
    };

    gl.genVertexArrays(1, @ptrCast(&vao));
    gl.genBuffers(1, @ptrCast(&vbo));
    gl.bindVertexArray(vao);
    gl.bindBuffer(gl.ARRAY_BUFFER, vbo);
    gl.bufferData(gl.ARRAY_BUFFER, @sizeOf(@TypeOf(vertices)), &vertices, gl.STATIC_DRAW);
    // Position
    gl.vertexAttribPointer(0, 3, gl.FLOAT, gl.FALSE, 0 * @sizeOf(f32), null);
    gl.enableVertexAttribArray(0);

    // Is this needed? Some kind of deinit.
    gl.bindBuffer(gl.ARRAY_BUFFER, 0);
    gl.bindVertexArray(0);

    const clock: Io.Clock = .boot;
    while (!glfw.windowShouldClose(window)) {
        glfw.pollEvents();
        if (window.getKey(.escape) == .press) {
            window.setShouldClose(true);
        }
        gl.clearColor(0.2, 0.3, 0.3, 1);
        gl.clear(gl.COLOR_BUFFER_BIT);

        shader.use();
        gl.bindVertexArray(vao);
        gl.drawArrays(gl.TRIANGLES, 0, 3);

        glfw.swapBuffers(window);
        try std.Io.sleep(io, .fromMilliseconds(16), clock);
    }
}
