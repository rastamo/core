const std = @import("std");
const builtin = @import("builtin");
const Io = std.Io;

const core = @import("core");
const gfx = core.graphics;

pub fn main(init: std.process.Init) !void {
    core.init();
    defer core.deinit();

    var window = try core.window.init();
    defer window.deinit();

    try gfx.init(init.io, init.gpa);
    defer gfx.deinit();

    var image = try gfx.Image.loadFromFile("assets/snake_l.png", 0);
    defer image.deinit();

    const texture = try gfx.create_texture(init.io, &image);
    std.log.debug("{}\n", .{texture});

    var input: core.Input = .init();
    var time: core.Time = .init(init.io);

    while (!window.shouldClose()) {
        time.update();
        input.poll();
        if (window.handle.getKey(.escape) == .press) {
            window.setShouldClose(true);
        }
        gfx.clearScreen();
        try gfx.draw_texture(texture);

        window.swapBuffers();
        try time.sleep();
        // std.log.info("dt: {d:.2} ms, fps: {d:.0}", .{ time.dt() * 1000, time.getFps() });
    }
}
