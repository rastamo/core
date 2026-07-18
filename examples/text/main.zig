const std = @import("std");
const builtin = @import("builtin");
const Io = std.Io;

const core = @import("core");
const gfx = core.graphics;

const gl = core.graphics.gl;

// Should be moved into core.
const TrueType = core.TrueType;

const Character = struct {
    id: u32,
    size: core.math.Vec2,
    bearing: core.math.Vec2,
    advance: f32,
};
var characters: [37]Character = undefined;
var vao: u32 = undefined;
var vbo: u32 = undefined;
const screen: Screen = .{};

const Screen = struct {
    width: f32 = 1920,
    height: f32 = 1080,
};

pub fn main(init: std.process.Init) !void {
    const io = init.io;
    const gpa = init.gpa;

    core.init();
    defer core.deinit();

    // Window creation -> platform/Window.zig
    var window = try core.Window.init();
    defer window.deinit();

    // Graphics -> graphics/gl.zig
    try gfx.init(io, gpa);

    // Graphics -> graphics/shaders/text.zig
    var shader = try core.graphics.Shader.init(.text);
    defer shader.deinit();
    const projection = core.zm.orthographicLh(screen.width, screen.height, 0.1, 100);
    shader.use();
    shader.setMat4("projection", projection);

    // Character loop
    const font = @import("assets").font;
    const ttf = try TrueType.load(font);
    const scale = ttf.scaleForPixelHeight(400);
    var buffer: std.ArrayListUnmanaged(u8) = .empty;
    defer buffer.deinit(gpa);
    var it = std.unicode.Utf8View.initComptime("How vexingly quick daft zebras jump!").iterator();
    gl.pixelStorei(gl.UNPACK_ALIGNMENT, 1);
    var i: usize = 0;
    while (it.nextCodepoint()) |codepoint| {
        const glyph = ttf.codepointGlyphIndex(codepoint);
        buffer.clearRetainingCapacity();
        const dims = ttf.glyphBitmap(gpa, &buffer, glyph, scale, scale) catch |err| switch (err) {
            error.GlyphNotFound => TrueType.GlyphBitmap.empty,
            else => return err,
        };
        const pixels = buffer.items;
        var id: u32 = undefined;
        gl.genTextures(1, @ptrCast(&id));
        gl.bindTexture(gl.TEXTURE_2D, id);
        gl.texImage2D(gl.TEXTURE_2D, 0, gl.RED, dims.width, dims.height, 0, gl.RED, gl.UNSIGNED_BYTE, @ptrCast(pixels.ptr));

        gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.CLAMP_TO_EDGE);
        gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.CLAMP_TO_EDGE);
        gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.NEAREST);
        gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.NEAREST);

        characters[i] = .{
            .id = id,
            .size = .{ .x = dims.width, .y = dims.height },
            .bearing = .{ .x = dims.off_x, .y = -dims.off_y },
            .advance = dims.width,
        };

        i += 1;
    }

    // Configure VAO/VBO for texture quads -> graphics/gl.zig
    gl.genVertexArrays(1, @ptrCast(&vao));
    gl.genBuffers(1, @ptrCast(&vbo));
    gl.bindVertexArray(vao);
    gl.bindBuffer(gl.ARRAY_BUFFER, vbo);
    gl.bufferData(gl.ARRAY_BUFFER, @sizeOf(f32) * 6 * 4, null, gl.DYNAMIC_DRAW);
    gl.vertexAttribPointer(0, 4, gl.FLOAT, gl.FALSE, 4 * @sizeOf(f32), null);
    gl.enableVertexAttribArray(0);

    // Is this needed? Some kind of deinit.
    // gl.bindBuffer(gl.ARRAY_BUFFER, 0);
    // gl.bindVertexArray(0);

    var input: core.Input = undefined;
    input.init(&window);
    var time: core.Time = .init(io);

    while (!window.shouldClose()) {
        time.update();
        input.poll();
        if (input.key(.escape).down) {
            window.setShouldClose(true);
        }
        if (input.key(.space).down) {
            std.log.info("Space is down.", .{});
        }
        gl.clearColor(0.2, 0.3, 0.3, 1);
        gl.clear(gl.COLOR_BUFFER_BIT);
        renderText(&shader);

        window.swapBuffers();
        try time.sleep();
    }
}

fn renderText(shader: *core.graphics.Shader) void {
    shader.use();
    shader.setVec3("text_color", .{ 1, 1, 1 });
    gl.activeTexture(gl.TEXTURE0);
    gl.bindVertexArray(vao);
    var x: f32 = -screen.width / 2;
    const y: f32 = 0;
    const scale: f32 = 1;
    for (characters) |ch| {
        const xpos = x + ch.bearing.x * scale;
        const ypos = y - (ch.size.y - ch.bearing.y) * scale;
        const w = ch.size.x * scale;
        const h = ch.size.y * scale;

        // std.log.debug("{any}", .{h});
        const vertices = [6][4]f32{
            .{ xpos, ypos + h, 0, 0 },
            .{ xpos, ypos, 0, 1 },
            .{ xpos + w, ypos, 1, 1 },
            .{ xpos, ypos + h, 0, 0 },
            .{ xpos + w, ypos, 1, 1 },
            .{ xpos + w, ypos + h, 1, 0 },
        };
        // std.log.debug("{any}", .{vertices});

        gl.bindTexture(gl.TEXTURE_2D, ch.id);
        gl.bindBuffer(gl.ARRAY_BUFFER, vbo);
        gl.bufferSubData(gl.ARRAY_BUFFER, 0, @sizeOf(@TypeOf(vertices)), &vertices);

        gl.bindBuffer(gl.ARRAY_BUFFER, 0);
        gl.drawArrays(gl.TRIANGLES, 0, 6);

        x += (ch.advance) * scale;
    }
    gl.bindVertexArray(0);
    gl.bindTexture(gl.TEXTURE_2D, 0);
}
