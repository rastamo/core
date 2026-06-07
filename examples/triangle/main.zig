const std = @import("std");
const builtin = @import("builtin");
const Io = std.Io;

const core = @import("core");
// const backend = core
const gfx = core.graphics;

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
    var vertex_array: gfx.VertexArray = .init(&vertices, &indices);
    vertex_array.addLayout(3, 3);

    var input: core.Input = .init();
    var time: core.Time = .init(io);

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
        // std.log.info("dt: {d:.2} ms, fps: {d:.0}", .{ time.dt() * 1000, time.getFps() });
    }
}
