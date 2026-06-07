const std = @import("std");
pub const opengl = @import("backends/opengl.zig");
pub const Shader = @import("Shader.zig");
pub const VertexArray = @import("VertexArray.zig");

// Should probably be updated.
pub const clearScreen: *const fn () void = opengl.clearScreen;
pub const draw = opengl.draw;
pub const drawElements = opengl.drawElements;

pub const vulkan = struct {
    pub fn draw() void {
        std.log.info("Hello from: {s}", .{"Vulkan"});
    }
};
