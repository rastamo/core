const Self = @This();
width: f32,
height: f32,

pub fn init(width: f32, height: f32) Self {
    return .{ .width = width, .height = height };
}
pub fn aspect(self: Self) f32 {
    return self.width / self.height;
}
pub fn size(self: Self) @Vector(2, f32) {
    return .{ self.width, self.height };
}
