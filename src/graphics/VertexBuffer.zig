const Self = @This();
const gl = @import("zopengl").bindings;

id: u32,

pub fn init(vertices: []const f32) Self {
    var vbo: Self = .{ .id = 0 };
    gl.genBuffers(1, &vbo.id);
    gl.bindBuffer(gl.ARRAY_BUFFER, vbo.id);
    gl.bufferData(gl.ARRAY_BUFFER, @intCast(@sizeOf(f32) * vertices.len), vertices.ptr, gl.STATIC_DRAW);
    return vbo;
}

pub fn bind(self: Self) void {
    gl.bindBuffer(gl.ARRAY_BUFFER, self.id);
}
pub fn unbind(_: Self) void {
    gl.bindBuffer(gl.ARRAY_BUFFER, 0);
}
