const math = @import("math.zig");
const Vec2 = math.Vec2;

pub const Rectangle = struct {
    position: Vec2,
    size: Vec2,
};
