// const Self = @This();
const std = @import("std");
const math = @import("../math.zig");
const Surface = @import("../Window.zig").Surface;
pub const zstbi = @import("zstbi");

const opengl = @import("backends/opengl/opengl.zig");
pub const Shader = opengl.Shader;
pub const VertexArray = opengl.VertexArray;
pub const clearScreen = opengl.clearScreen;
const gl = opengl.gl;

pub fn init(io: std.Io, gpa: std.mem.Allocator) !void {
    try opengl.init();
    try initTexture(io, gpa);
}

pub fn deinit() void {
    // Deinit texture setup
    zstbi.deinit();
}

fn initTexture(io: std.Io, gpa: std.mem.Allocator) !void {
    zstbi.init(io, gpa);
    zstbi.setFlipVerticallyOnLoad(true);
}
pub const Image = zstbi.Image;

pub const Texture = struct {
    id: u32,
    shader: opengl.Shader,
    vertex_array: opengl.VertexArray,
};

pub fn createTexture(io: std.Io, image: *const Image) !Texture {
    _ = io;
    const shader = Shader.init(
        // io,
        // "src/graphics/backends/opengl/shaders/texture.vs",
        // "src/graphics/backends/opengl/shaders/texture.fs",
    ) catch |err| {
        std.log.err("Error creating shader: {}\n", .{err});
        return err;
    };
    // defer shader.deinit();

    // Position, color and texture
    const vertices: [8 * 4]f32 = .{
        -0.5, 0.5, 0.0, 1, 0, 0, 0, 1, // top left
        0.5, 0.5, 0.0, 0, 1, 0, 1, 1, // top right
        0.5, -0.5, 0.0, 0, 0, 1, 1, 0, // bottom right
        -0.5, -0.5, 0.0, 1, 1, 0, 0, 0, // bottom left
    };
    const indices = [6]u32{
        0, 1, 2,
        0, 2, 3,
    };
    var vertex_array: VertexArray = .init(&vertices, &indices);
    const stride = 8 * @sizeOf(@TypeOf(vertices[0]));
    vertex_array.addLayout(3, stride);
    vertex_array.addLayout(3, stride);
    vertex_array.addLayout(2, stride);

    var texture: c_uint = undefined;
    gl.genTextures(1, &texture);
    std.log.debug("id: {}\n", .{texture});
    gl.bindTexture(gl.TEXTURE_2D, texture);
    gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.CLAMP_TO_EDGE);
    gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.CLAMP_TO_EDGE);
    gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR);
    gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.LINEAR);

    gl.texImage2D(
        gl.TEXTURE_2D,
        0,
        gl.RGBA,
        @intCast(image.width),
        @intCast(image.height),
        0,
        gl.RGBA,
        gl.UNSIGNED_BYTE,
        @ptrCast(image.data),
    );
    gl.generateMipmap(gl.TEXTURE_2D);

    gl.bindBuffer(gl.ARRAY_BUFFER, 0);
    gl.bindVertexArray(0);

    return Texture{
        .id = texture,
        .shader = shader,
        .vertex_array = vertex_array,
    };
}

pub fn drawTexture(texture: Texture) !void {
    texture.shader.use();
    texture.vertex_array.bind();
    opengl.drawElements();
}
