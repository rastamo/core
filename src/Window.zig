const Self = @This();
// const window_icon = @embedFile("window_icon");
const std = @import("std");
const glfw = @import("zglfw");
const gl = @import("graphics/backends/opengl/opengl.zig");
const builtin = @import("builtin");
const m = @import("math.zig");

handle: *glfw.Window = undefined,
is_fullscreen: bool = true,
size: m.Size = undefined,

pub fn init() !Self {
    var self: Self = .{};

    try glfw.init();
    glfw.windowHint(.client_api, .opengl_api);
    glfw.windowHint(.context_version_major, gl.Version.major);
    glfw.windowHint(.context_version_minor, gl.Version.minor);
    glfw.windowHint(.opengl_profile, .opengl_core_profile);
    glfw.windowHint(.doublebuffer, true);
    glfw.windowHintString(.wayland_app_id, "Game");
    glfw.windowHint(.samples, 8);
    if (builtin.os.tag == .macos) {
        glfw.windowHint(.opengl_forward_compat, true);
    }

    const monitor = glfw.getPrimaryMonitor();
    const video_mode = try glfw.getVideoMode(monitor.?);
    self.size = .{ .width = @floatFromInt(video_mode.width), .height = @floatFromInt(video_mode.height) };
    // Users should be able to set title, and maybe window size.
    self.handle = try glfw.createWindow(video_mode.width, video_mode.height, "Core", glfw.getPrimaryMonitor(), null);
    glfw.makeContextCurrent(self.handle);
    self.setVSync(false);

    // const icons = [_]glfw.Image{.{ .pixels = @constCast(window_icon), .height = 32, .width = 32 }};
    // glfw.setWindowIcon(self.handle, &icons);
    // try gl.init();
    return self;
}

pub fn deinit(self: *Self) void {
    self.handle.destroy();
    glfw.terminate();
}

pub const Surface = struct { native: *anyopaque };
pub fn createSurface(self: *Self) Surface {
    return Surface{ .native = @ptrCast(self.handle) };
}

pub fn shouldClose(self: Self) bool {
    return self.handle.shouldClose();
}
pub fn setShouldClose(self: Self, answer: bool) void {
    return self.handle.setShouldClose(answer);
}
pub fn swapBuffers(self: Self) void {
    self.handle.swapBuffers();
}
pub fn setVSync(_: Self, value: bool) void {
    glfw.swapInterval(@intFromBool(value));
}

pub fn toggleFullscreen(self: *Self) void {
    // Debug this on Windows.
    self.is_fullscreen = !self.is_fullscreen;
    if (self.is_fullscreen) {
        self.handle.setMonitor(null, 100, 100, 100, 100, 0);
    } else {
        self.handle.setMonitor(glfw.getPrimaryMonitor(), 0, 0, 100, 100, 0);
    }
    // std.debug.print("{}\n", .{"test"});
}
