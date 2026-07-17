const Self = @This();

const opengl = @import("backends/opengl/opengl.zig");
const Screen = @import("../Screen.zig");
const Camera = @import("../Camera.zig");
const gfx = @import("graphics.zig");
const Texture = gfx.Texture;
const m = @import("../math.zig");
const zm = @import("zmath");

var time: f32 = 0;
screen: Screen,
camera: Camera = .{},

pub fn init(width: f32, height: f32) Self {
    return .{
        .screen = .{ .width = width, .height = height },
    };
}

// Probably need update function here to handle resizing of window.
// It need to take a size or a Window.

pub fn clearScreen(_: Self) void {
    opengl.clearScreen();
}

pub fn drawTexture(self: *Self, texture: gfx.Texture, position: m.Vec3, rotation: f32, scale: m.Vec3) !void {
    texture.shader.use();
    texture.shader.setInt("tex", @as(i32, @intCast(texture.unit)));
    texture.bind();

    // Projection
    const projection = self.camera.getProjection(self.screen);
    texture.shader.setMat4("projection", projection);

    // View
    const view = self.camera.getView();
    texture.shader.setMat4("view", view);

    // Model
    var model: [4]@Vector(4, f32) = undefined;
    model = zm.translation(position.x, position.y, position.z);
    model = zm.mul(zm.rotationZ(rotation), model);
    model = zm.mul(zm.scaling(scale.x, scale.y, scale.z), model);
    texture.shader.setMat4("model", model);

    // Draw
    texture.vertex_array.bind();
    opengl.drawElements();
}
