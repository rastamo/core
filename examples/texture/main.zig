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
    const texture = try gfx.createTexture(init.io, &image);
    image.deinit();

    var input: core.Input = .init();
    var time: core.Time = .init(init.io);
    var render: gfx.Render = .init(1920, 1080); // Should not be provided manually.

    while (!window.shouldClose()) {
        time.update();
        input.poll();
        if (window.handle.getKey(.escape) == .press) {
            window.setShouldClose(true);
        }

        render.clearScreen();
        // try render.drawTexture(texture, .{ .x = @cos(time.time) * 5, .y = @sin(time.time) * 3, .z = 0 }, time.time * 2, .{ .x = time.time, .y = time.time });
        try render.drawTexture(
            texture,
            .{},
            0,
            .{ .x = 16, .y = 9 },
        );

        window.swapBuffers();
        try time.sleep();
        // std.log.info("dt: {d:.2} ms, fps: {d:.0}", .{ time.dt() * 1000, time.getFps() });
    }
}
