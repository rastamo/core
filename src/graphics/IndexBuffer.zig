const Self = @This();
const gl = @import("zopengl").bindings;

id: u32,
count: usize,

pub fn init(indices: []const u32) Self {
    var ebo = Self{ .id = 0, .count = indices.len };
    gl.genBuffers(1, &ebo.id);
    gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, ebo.id);
    gl.bufferData(gl.ELEMENT_ARRAY_BUFFER, @intCast(@sizeOf(u32) * indices.len), indices.ptr, gl.STATIC_DRAW);
    return ebo;
}

pub fn bind(self: Self) void {
    gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, self.id);
}
pub fn unbind(_: Self) void {
    gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, 0);
}
