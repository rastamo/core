const Self = @This();
const gl = @import("zopengl").bindings;
const VertexBuffer = @import("VertexBuffer.zig");
const IndexBuffer = @import("IndexBuffer.zig");

id: u32,
vbo: VertexBuffer,
ebo: IndexBuffer,

pub fn init(vertices: []const f32, indices: []const u32) Self {
    var vao: u32 = 0;
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

pub fn addLayout(self: Self) void {
    // TODO: This function need to be expanded to allow multiple layouts.
    self.bind();
    gl.vertexAttribPointer(0, 3, gl.FLOAT, gl.FALSE, 0 * @sizeOf(f32), null);
    gl.enableVertexAttribArray(0);
}
