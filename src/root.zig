const std = @import("std");
pub const graphics = struct {
    pub const Shader = @import("graphics/Shader.zig");
    pub const VertexArray = @import("graphics/VertexArray.zig");
    pub const opengl = @import("graphics/backends/opengl.zig");

    pub const clearScreen: *const fn () void = opengl.clearScreen;
    pub const draw = opengl.draw;
    pub const drawElements = opengl.drawElements;
};

pub const math = @import("math.zig");
pub const window = @import("Window.zig");
pub const Input = @import("Input.zig");
pub const log = @import("log.zig");
pub const Time = @import("Time.zig");
pub const zstbi = @import("zstbi");

pub const recommended_std_options: std.Options = .{ .logFn = log.log };

pub fn init() void {
    std.log.info("Core Library", .{});
}

pub fn deinit() void {
    std.log.info("Exiting application.", .{});
}
