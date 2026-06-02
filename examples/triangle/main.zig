const std = @import("std");
const builtin = @import("builtin");
const Io = std.Io;

// This file should only take engine as dependency.
const core = @import("core");
const zopengl = @import("zopengl");
const gl = zopengl.bindings;

pub fn main(init: std.process.Init) !void {
    const io = init.io;
    std.debug.print("{s}\n", .{"Core library"});

    var window = try core.window.init();
    defer window.deinit();

    var shader = try core.graphics.Shader.init(io, "src/graphics/shaders/triangle.vs", "src/graphics/shaders/triangle.fs");
    defer shader.deinit();
    shader.use();

    const vertices = [_]f32{
        -0.5, -0.5, 0,
        0,    0.5,  0,
        0.5,  -0.5, 0,
    };
    const indices = [_]u32{
        0, 1, 2,
    };

    const vertex_array: core.graphics.gl.VertexArray = .init(&vertices, &indices);
    vertex_array.bind();

    // Position
    gl.vertexAttribPointer(0, 3, gl.FLOAT, gl.FALSE, 0 * @sizeOf(f32), null);
    gl.enableVertexAttribArray(0);

    const clock: Io.Clock = .boot;
    var input: core.Input = .init();
    while (!window.shouldClose()) {
        input.poll();
        if (window.handle.getKey(.escape) == .press) {
            window.setShouldClose(true);
        }
        core.graphics.gl.clearScreen();

        shader.use();
        vertex_array.bind();
        core.graphics.gl.draw();

        window.swapBuffers();
        try std.Io.sleep(io, .fromMilliseconds(16), clock);
    }
}
