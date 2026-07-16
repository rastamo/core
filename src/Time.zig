const Self = @This();
const std = @import("std");

const period: i96 = 16_666_667;

delta: i96 = period,
last_frame: i96 = 0,
clock: std.Io.Clock = .boot,
io: std.Io,
time: f32 = 0,
start: i96 = 0,

pub fn init(io: std.Io) Self {
    var self: Self = .{
        .io = io,
    };
    self.start = self.now();
    self.last_frame = self.now() - period;

    return self;
}

fn now(self: Self) i96 {
    return self.clock.now(self.io).toNanoseconds();
}

pub fn update(self: *Self) void {
    const current_time = self.now();
    self.delta = current_time - self.last_frame;
    self.last_frame = current_time;

    self.time = @as(f32, @floatFromInt(current_time - self.start)) * 1e-9;
}

pub fn sleep(self: *Self) !void {
    const elapsed = self.now() - self.last_frame;
    const time_to_sleep = period - elapsed;
    try self.io.sleep(.fromNanoseconds(time_to_sleep), self.clock);
}

/// Returns delta time in seconds
pub fn dt(self: Self) f32 {
    return @as(f32, @floatFromInt(self.delta)) * 1e-9;
}

pub fn getFps(self: *Self) f32 {
    return 1 / self.dt();
}
