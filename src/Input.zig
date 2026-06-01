const Self = @This();
const std = @import("std");
const Vec2 = @import("math.zig").Vec2;

const Window = @import("Window.zig");
const glfw = @import("zglfw");

pub const Mouse = struct {
    x: f32 = 0,
    y: f32 = 0,
    scroll: f32 = 45,
    pub fn position(self: Mouse) Vec2 {
        return Vec2{ .x = self.x, .y = self.y };
    }
};

const Keyboard = struct {};
const Key = struct {
    down: bool = false,
    rising: bool = false,
    falling: bool = false,
    none: bool = true,
};

mouse: Mouse = .{},
keyboard: Keyboard = .{},
// 348 is the last glfw.Key value.
keys: [348 + 1]Key = .{Key{}} ** 349,
previous_keys: [348 + 1]Key = .{Key{}} ** 349,

pub fn init() Self {
    const self: Self = .{};
    return self;
}

pub fn setup(self: *Self, window: *Window) void {
    glfw.setWindowUserPointer(window.handle, &self.mouse);
    _ = glfw.setCursorPosCallback(window.handle, Self.mouse_callback);
    _ = glfw.setScrollCallback(window.handle, Self.scroll_callback);
    _ = glfw.setKeyCallback(window.handle, Self.key_callback);
}

pub fn poll(self: *Self) void {
    glfw.pollEvents();
    for (0..self.keys.len) |i| {
        const previous = &self.previous_keys[i];
        const current = &self.keys[i];
        current.falling = current.down and !previous.down;
        current.rising = previous.down and !current.down;
        previous.* = current.*;
    }
}

pub fn key(self: Self, key_enum: glfw.Key) Key {
    return self.keys[@as(usize, @intCast(@intFromEnum(key_enum)))];
}

pub fn mouse_callback(window: *glfw.Window, xpos: f64, ypos: f64) callconv(.c) void {
    const maybe_input = glfw.getWindowUserPointer(window, Self);
    if (maybe_input) |input| {
        input.mouse.x = @floatCast(xpos);
        input.mouse.y = @floatCast(ypos);
    }
}

pub fn scroll_callback(window: *glfw.Window, _: f64, yoffset: f64) callconv(.c) void {
    // _ = xoffset;
    const maybe_input = glfw.getWindowUserPointer(window, Self);
    if (maybe_input) |input| {
        const change: f32 = @floatCast(yoffset);
        input.mouse.scroll = std.math.clamp(input.mouse.scroll - change, 1, 45);
    }
}

pub fn key_callback(window: *glfw.Window, key_enum: glfw.Key, scancode: i32, action: glfw.Action, mods: glfw.Mods) callconv(.c) void {
    if (key_enum == .unknown) return;
    _ = scancode;
    _ = mods;
    const maybe_input = glfw.getWindowUserPointer(window, Self);
    if (maybe_input) |input| {
        const index: usize = @intCast(@intFromEnum(key_enum));
        switch (action) {
            .press => {
                input.keys[index] = Key{ .down = true };
            },
            .release => {
                input.keys[index] = Key{ .down = false };
            },
            .repeat => {
                input.keys[index] = Key{ .down = true };
            },
        }
    }
}
