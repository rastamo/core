const std = @import("std");
pub const zstbi = @import("zstbi");

pub const graphics = @import("graphics/graphics.zig");
pub const math = @import("math.zig");
pub const window = @import("Window.zig");
pub const Input = @import("Input.zig");
pub const log = @import("log.zig");
pub const Time = @import("Time.zig");

pub const recommended_std_options: std.Options = .{ .logFn = log.log };

pub const Backend = enum {
    opengl,
    vulkan, // Not impl yet.

    pub fn impl(comptime self: Backend) type {
        return switch (self) {
            .opengl => graphics.opengl,
            .vulkan => graphics.vulkan,
        };
    }
};

pub fn Graphics(comptime backend: type) type {
    // const impl = Backend.impl(backend);
    return struct {
        pub fn draw() void {
            backend.draw();
        }
    };
}

pub fn init() void {
    // comptime var gfx = 0;
    // switch (backend) {
    //     .vulkan => gfx = @import("graphics/graphics.zig"),
    //     else => gfx = @import("graphics/graphics.zig"),
    // }
    std.log.info("Core Library", .{});
}

pub fn deinit() void {
    std.log.info("Exiting application.", .{});
}

// pub fn (comptime backend:Backend
