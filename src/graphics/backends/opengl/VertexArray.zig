const Self = @This();
const gl = @import("zopengl").bindings;
const VertexBuffer = @import("VertexBuffer.zig");
const IndexBuffer = @import("IndexBuffer.zig");

id: u32,
vbo: VertexBuffer,
ebo: IndexBuffer,
layout_index: u32 = 0,
len_counter: u32 = 0,

pub fn init(vertices: []const f32, indices: []const u32) Self {
    var vao: u32 = undefined;
    gl.genVertexArrays(1, &vao);
    gl.bindVertexArray(vao);

    return .{ .id = vao, .vbo = .init(vertices), .ebo = .init(indices) };
}

pub fn bind(self: Self) void {
    gl.bindVertexArray(self.id);
}

pub fn unbind(_: Self) void {
    gl.bindVertexArray(0);
}

pub fn indexCount(self: Self) usize {
    return self.ebo.count;
}

pub fn addLayout(self: *Self, len: u32, stride: u32) void {
    // This function need a friendlier ux.
    gl.vertexAttribPointer(self.layout_index, @intCast(len), gl.FLOAT, gl.FALSE, @intCast(stride), @ptrFromInt(self.len_counter * @sizeOf(f32)));
    gl.enableVertexAttribArray(self.layout_index);
    self.layout_index += 1;
    self.len_counter += len;
}
