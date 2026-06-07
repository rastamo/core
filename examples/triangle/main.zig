const std = @import("std");
const builtin = @import("builtin");
const Io = std.Io;

const core = @import("core");
const gfx = core.graphics;

// Currently only enables colored logs.
// pub const std_options: std.Options = core.recommended_std_options;

pub fn main(init: std.process.Init) !void {
    const io = init.io;
    core.init();
    defer core.deinit();

    var window = try core.window.init();
    defer window.deinit();
    window.setVSync(false);

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
    const indices = [_]u32{ 0, 1, 2 };
    const vertex_array: gfx.VertexArray = .init(&vertices, &indices);
    vertex_array.addLayout();

    var input: core.Input = .init();
    var time: core.Time = .init(io);
    // try time.sleep();
    while (!window.shouldClose()) {
        time.update();
        input.poll();
        if (window.handle.getKey(.escape) == .press) {
            window.setShouldClose(true);
        }
        gfx.clearScreen();

        shader.use();
        vertex_array.bind();
        gfx.draw();

        window.swapBuffers();
        try time.sleep();
        std.log.info("FPS: {}", .{time.getFps()});
    }
}
