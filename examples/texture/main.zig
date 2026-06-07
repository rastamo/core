const std = @import("std");
const builtin = @import("builtin");
const Io = std.Io;

const core = @import("core");
const zstbi = core.zstbi;
const gfx = core.graphics;

pub fn main(init: std.process.Init) !void {
    const io = init.io;
    const allocator = init.gpa;
    zstbi.init(io, allocator);
    defer zstbi.deinit();
    zstbi.setFlipVerticallyOnLoad(true);

    core.init();
    defer core.deinit();

    var window = try core.window.init();
    defer window.deinit();
    window.setVSync(false);

    var shader = core.graphics.Shader.init(io, "src/graphics/shaders/texture.vs", "src/graphics/shaders/texture.fs") catch |err| {
        std.log.err("Error creating shader: {}\n", .{err});
        return;
    };
    defer shader.deinit();

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
    var vertex_array: gfx.VertexArray = .init(&vertices, &indices);
    const stride = 8 * @sizeOf(@TypeOf(vertices[0]));
    vertex_array.addLayout(3, stride);
    vertex_array.addLayout(3, stride);
    vertex_array.addLayout(2, stride);

    const gl = core.graphics.opengl.gl;
    var texture: c_uint = undefined;
    gl.genTextures(1, &texture);
    gl.bindTexture(gl.TEXTURE_2D, texture);
    gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.CLAMP_TO_EDGE);
    gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.CLAMP_TO_EDGE);
    gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR);
    gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.LINEAR);

    var image = try zstbi.Image.loadFromFile("assets/snake_l.png", 0);
    defer image.deinit();
    const width: c_int = @intCast(image.width);
    const height: c_int = @intCast(image.height);
    // std.debug.print("{}", .{image.width});
    gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGBA, width, height, 0, gl.RGBA, gl.UNSIGNED_BYTE, @ptrCast(image.data));
    gl.generateMipmap(gl.TEXTURE_2D);

    gl.bindBuffer(gl.ARRAY_BUFFER, 0);
    gl.bindVertexArray(0);

    var input: core.Input = .init();
    var time: core.Time = .init(io);

    while (!window.shouldClose()) {
        time.update();
        input.poll();
        if (window.handle.getKey(.escape) == .press) {
            window.setShouldClose(true);
        }
        gfx.clearScreen();

        shader.use();
        vertex_array.bind();
        gfx.drawElements();

        window.swapBuffers();
        try time.sleep();
        // std.log.info("dt: {d:.2} ms, fps: {d:.0}", .{ time.dt() * 1000, time.getFps() });
    }
}
