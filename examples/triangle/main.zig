const std = @import("std");
const builtin = @import("builtin");
const Io = std.Io;

const core = @import("core");
const gfx = core.graphics;

// Currently only enables colored logs.
pub const std_options: std.Options = core.recommended_std_options;

pub fn main(init: std.process.Init) !void {
    const io = init.io;
    core.init();
    defer core.deinit();

    var window = try core.window.init();
    defer window.deinit();

    var shader = core.graphics.Shader.init(io, "src/graphics/shaders/triangle.vs", "src/graphics/shaders/triangle.fs") catch |err| {
        std.log.err("Error creating shader: {}\n", .{err});
        return;
    };
    defer shader.deinit();

    const vertices = [_]f32{
        -0.5, -0.5, 0,
        0,    0.5,  0,
        0.5,  -0.5, 0,
    };
    const indices = [_]u32{
        0, 1, 2,
    };

    const vertex_array: gfx.VertexArray = .init(&vertices, &indices);
    vertex_array.addLayout();

    const clock: Io.Clock = .boot;
    var input: core.Input = .init();
    while (!window.shouldClose()) {
        input.poll();
        if (window.handle.getKey(.escape) == .press) {
            window.setShouldClose(true);
        }
        gfx.clearScreen();

        shader.use();
        vertex_array.bind();
        gfx.draw();

        window.swapBuffers();

        // Add proper sleep based on time elapsed.
        try std.Io.sleep(io, .fromMilliseconds(16), clock);
    }
}
