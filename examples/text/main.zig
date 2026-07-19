const std = @import("std");
const builtin = @import("builtin");
const Io = std.Io;

const core = @import("core");
const gfx = core.graphics;

pub fn main(init: std.process.Init) !void {
    const io = init.io;
    const gpa = init.gpa;

    core.init();
    defer core.deinit();

    var window = try core.Window.init();
    defer window.deinit();

    // Can Renderer deal with this?
    try gfx.init(io, gpa);

    var render = gfx.Renderer.init(gpa, window.size);

    var input: core.Input = undefined;
    input.init(&window);
    var time: core.Time = .init(io);

    while (!window.shouldClose()) {
        time.update();
        input.poll();
        if (input.key(.escape).down) {
            window.setShouldClose(true);
        }
        if (input.key(.space).down) {
            std.log.info("Space is down.", .{});
        }
        render.clear();
        try render.text("How vexingly quick daft Zebras jump.", .{ .x = 100 });

        window.swapBuffers();
        try time.sleep();
    }
}
