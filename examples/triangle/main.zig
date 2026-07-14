const std = @import("std");
const builtin = @import("builtin");
const Io = std.Io;

const core = @import("core");
const gfx = core.graphics;

pub fn main(init: std.process.Init) !void {
    const io = init.io;
    core.init();
    defer core.deinit();

    var window = try core.window.init();
    defer window.deinit();
    window.setVSync(false);

    try gfx.init(io, init.gpa);
    // Abstract out!
    var shader = gfx.Shader.init(
        io,
        "src/graphics/backends/opengl/shaders/triangle.vs",
        "src/graphics/backends/opengl/shaders/triangle.fs",
    ) catch |err| {
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
    vertex_array.addLayout(3, 0);

    var input: core.Input = .init();
    var time: core.Time = .init(io);
    // core.graphics.opengl.polygonMode();

    while (!window.shouldClose()) {
        time.update();
        input.poll();
        // Down use handle directly.
        if (window.handle.getKey(.escape) == .press) {
            window.setShouldClose(true);
        }
        gfx.clearScreen();

        shader.use();
        vertex_array.bind();
        gfx.triangle();

        window.swapBuffers();
        try time.sleep();
        // std.log.info("dt: {d:.2} ms, fps: {d:.0}", .{ time.dt() * 1000, time.getFps() });
    }
}
