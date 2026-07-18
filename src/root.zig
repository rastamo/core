const std = @import("std");
pub const zstbi = @import("zstbi");

pub const graphics = @import("graphics/graphics.zig");
pub const math = @import("math.zig");
pub const Window = @import("Window.zig");
pub const Input = @import("Input.zig");
pub const log = @import("log.zig");
pub const Time = @import("Time.zig");

// Should not be public
pub const zm = @import("zmath");
pub const TrueType = @import("TrueType");

pub const recommended_std_options: std.Options = .{ .logFn = log.log };

pub fn init() void {
    std.log.info("Core Library", .{});
}

pub fn deinit() void {
    std.log.info("Exiting application", .{});
}
