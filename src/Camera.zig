const Self = @This();
const std = @import("std");
const zm = @import("zmath");
const Screen = @import("Screen.zig");

const Mouse = @import("Input.zig").Mouse;

position: zm.Vec = .{ 0, 0, 5, 0 },
front: zm.Vec = .{ 0, 0, -1, 0 },
up: zm.Vec = .{ 0, 1, 0, 0 },
last: Mouse = .{},
yaw: f32 = 0,
pitch: f32 = 0,
zoom: f32 = 1,
fov: f32 = 50, // Not allowed to be zero.
view_width: f32 = 16.0, // Should be decided by game.

pub fn setFov(self: *Self, fov: f32) void {
    self.fov = fov;
}

pub fn getProjection(self: Self, screen: Screen) zm.Mat {
    return zm.orthographicRhGl(self.view_width, self.view_width / screen.aspect(), -1000, 1000);
}

pub fn getView(self: *Self) zm.Mat {
    return zm.lookAtRh(self.position, self.position + self.front, self.up);
}
