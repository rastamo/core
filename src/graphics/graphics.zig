// const Self = @This();
const std = @import("std");
const Surface = @import("../Window.zig").Surface;

pub const opengl = @import("backends/opengl/opengl.zig");
pub const vulkan = @import("backends/vulkan/vulkan.zig");

pub const Backend = enum {
    default,
    opengl,
    vulkan, // Not impl yet.

    pub fn impl(comptime self: Backend) type {
        return switch (self) {
            .default => opengl,
            .opengl => opengl,
            .vulkan => vulkan,
        };
    }
};

pub fn backend(comptime b: Backend) type {
    const impl = Backend.impl(b);
    return struct {
        pub const Texture = struct {
            shader: Shader,
            va: VertexArray,
        };
        pub const opengl = impl;
        pub const Shader = impl.Shader;
        pub const VertexArray = impl.VertexArray;
        pub const init = impl.init;
        pub const clearScreen = impl.clearScreen;
        pub const drawElements = impl.drawElements;
        pub fn triangle() void {
            impl.drawElements();
        }
    };
}
