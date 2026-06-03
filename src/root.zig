const std = @import("std");
pub const graphics = struct {
    pub const Shader = @import("graphics/Shader.zig");
    pub const gl = @import("gl.zig");
};

pub const math = @import("math.zig");
pub const window = @import("Window.zig");
pub const Input = @import("Input.zig");
pub const log = @import("log.zig");

pub const recommended_std_options: std.Options = .{ .logFn = log.log };

pub fn init() void {
    std.log.info("Core Library", .{});
}

pub fn deinit() void {}
