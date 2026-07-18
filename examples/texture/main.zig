const std = @import("std");
const builtin = @import("builtin");
const Io = std.Io;

const core = @import("core");
const gfx = core.graphics;

pub fn main(init: std.process.Init) !void {
    core.init();
    defer core.deinit();

    var window = try core.Window.init();
    defer window.deinit();

    try gfx.init(init.io, init.gpa);
    defer gfx.deinit();

    var image = try gfx.Image.loadFromFile("assets/snake_l.png", 0);
    const snake = try gfx.createTexture(init.io, &image);
    defer image.deinit();
    std.log.debug("{}", .{snake});

    var image2 = try gfx.Image.loadFromFile("assets/icon.png", 0);
    const icon = try gfx.createTexture(init.io, &image2);
    defer image2.deinit();
    std.log.debug("{}", .{icon});

    var input: core.Input = .init(&window);
    var time: core.Time = .init(init.io);
    var renderer: gfx.Renderer = .init(window.width, window.height); // Should not be provided manually.

    while (!window.shouldClose()) {
        time.update();
        input.poll();
        if (window.handle.getKey(.escape) == .press) {
            window.setShouldClose(true);
        }

        renderer.clearScreen();
        // try render.drawTexture(texture, .{ .x = @cos(time.time) * 5, .y = @sin(time.time) * 3, .z = 0 }, time.time * 2, .{ .x = time.time, .y = time.time });
        try renderer.drawTexture(snake, .{ .x = -4 }, 0, .{ .x = 4, .y = 2 });
        try renderer.drawTexture(icon, .{ .x = 4 }, 0, .{ .x = 2, .y = 1 });

        window.swapBuffers();
        try time.sleep();
        // std.log.info("dt: {d:.2} ms, fps: {d:.0}", .{ time.dt() * 1000, time.getFps() });
    }
}
