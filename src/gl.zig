const zopengl = @import("zopengl");
const gl = zopengl.bindings;
const glfw = @import("zglfw");

const Rgba = struct { r: f32 = 0.8, g: f32 = 0.2, b: f32 = 0.8, a: f32 = 1.0 };
const debug: Rgba = .{};

pub const Version = struct {
    pub const major: u16 = 3;
    pub const minor: u16 = 3;
};
pub fn init() !void {
    try zopengl.loadCoreProfile(@ptrCast(&glfw.getProcAddress), Version.major, Version.minor);
    // gl.enable(gl.DEPTH_TEST); // This is needed for proper 3D, however 2D overlay won't work.
    gl.enable(gl.MULTISAMPLE);
    gl.enable(gl.LINE_SMOOTH);
    // gl.enable(gl.CULL_FACE);
    // gl.enable(gl.BLEND); // PNG ALPHA
    // gl.blendFunc(gl.SRC_ALPHA, gl.ONE_MINUS_SRC_ALPHA); // PNG ALPHA
}

pub fn clearScreen() void {
    // gl.clearColor(debug.r, debug.g, debug.b, debug.a);
    gl.clearColor(0.1, 0.15, 0.2, 1.0);
    gl.clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT);
}

pub fn polygonMode() void {
    gl.polygonMode(gl.FRONT_AND_BACK, gl.LINE);
}

pub fn draw() void {
    gl.drawArrays(gl.TRIANGLES, 0, 3);
}

pub const VertexBuffer = struct {
    id: u32,

    pub fn init(vertices: []const f32) VertexBuffer {
        var vbo = VertexBuffer{ .id = 0 };
        gl.genBuffers(1, &vbo.id);
        gl.bindBuffer(gl.ARRAY_BUFFER, vbo.id);
        gl.bufferData(gl.ARRAY_BUFFER, @intCast(@sizeOf(f32) * vertices.len), vertices.ptr, gl.STATIC_DRAW);
        return vbo;
    }

    pub fn bind(self: VertexBuffer) void {
        gl.bindBuffer(gl.ARRAY_BUFFER, self.id);
    }
    pub fn unbind(_: VertexBuffer) void {
        gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, 0);
    }
};
pub const IndexBuffer = struct {
    id: u32,
    count: usize,

    pub fn init(indices: []const u32) IndexBuffer {
        var ebo = IndexBuffer{ .id = 0, .count = indices.len };
        gl.genBuffers(1, &ebo.id);
        gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, ebo.id);
        gl.bufferData(gl.ELEMENT_ARRAY_BUFFER, @intCast(@sizeOf(u32) * indices.len), indices.ptr, gl.STATIC_DRAW);
        return ebo;
    }

    pub fn bind(self: IndexBuffer) void {
        gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, self.id);
    }
    pub fn unbind(_: IndexBuffer) void {
        gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, 0);
    }
};

pub const VertexArray = struct {
    id: u32,
    vbo: VertexBuffer,
    ebo: IndexBuffer,

    pub fn init(vertices: []const f32, indices: []const u32) VertexArray {
        var vao: u32 = 0;
        gl.genVertexArrays(1, &vao);
        gl.bindVertexArray(vao);

        return .{ .id = vao, .vbo = VertexBuffer.init(vertices), .ebo = IndexBuffer.init(indices) };
    }

    pub fn bind(self: VertexArray) void {
        gl.bindVertexArray(self.id);
    }
    pub fn unbind(_: VertexArray) void {
        gl.bindVertexArray(0);
    }
    pub fn indexCount(self: VertexArray) usize {
        return self.ebo.count;
    }
};
