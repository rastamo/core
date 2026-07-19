const Self = @This();
const std = @import("std");

const opengl = @import("backends/opengl/opengl.zig");
const Screen = @import("../Screen.zig");
const Camera = @import("../Camera.zig");
const gfx = @import("graphics.zig");
const Texture = gfx.Texture;
const m = @import("../math.zig");
const zm = @import("zmath");
const gl = gfx.gl;

var time: f32 = 0;
screen: Screen,
camera: Camera = .{},
gpa: std.mem.Allocator = undefined,

pub fn init(gpa: std.mem.Allocator, size: m.Size) Self {
    return .{
        .gpa = gpa,
        .screen = .{ .width = size.width, .height = size.height },
    };
}

// Probably need update function here to handle resizing of window.
// It need to take a size or a Window.

pub fn clear(_: Self) void {
    opengl.clearScreen();
}

pub fn texture(self: *Self, tex: gfx.Texture, position: m.Vec3, rotation: f32, scale: m.Vec3) !void {
    tex.shader.use();
    tex.shader.setInt("tex", @as(i32, @intCast(tex.unit)));
    tex.bind();

    // Projection
    const projection = self.camera.getProjection(self.screen);
    tex.shader.setMat4("projection", projection);

    // View
    const view = self.camera.getView();
    tex.shader.setMat4("view", view);

    // Model
    var model: [4]@Vector(4, f32) = undefined;
    model = zm.translation(position.x, position.y, position.z);
    model = zm.mul(zm.rotationZ(rotation), model);
    model = zm.mul(zm.scaling(scale.x, scale.y, scale.z), model);
    tex.shader.setMat4("model", model);

    // Draw
    tex.vertex_array.bind();
    opengl.drawElements();
}

const TrueType = @import("TrueType");

const Character = struct {
    id: u32,
    size: m.Vec2,
    bearing: m.Vec2,
    advance: f32,
};
var characters: [37]Character = undefined;
var vao: u32 = undefined;
var vbo: u32 = undefined;

pub fn text(self: *Self, str: []const u8, position: m.Vec2) !void {
    var shader = try gfx.Shader.init(.text);
    defer shader.deinit();
    const projection = zm.orthographicLh(self.screen.width, self.screen.height, 0.1, 100);
    shader.use();
    shader.setMat4("projection", projection);

    const font = @import("assets").font;
    const ttf = try TrueType.load(font);
    var scale = ttf.scaleForPixelHeight(400);
    var buffer: std.ArrayListUnmanaged(u8) = .empty;
    defer buffer.deinit(self.gpa);
    const view = try std.unicode.Utf8View.init(str);
    var it = view.iterator();
    gl.pixelStorei(gl.UNPACK_ALIGNMENT, 1);
    var i: usize = 0;
    while (it.nextCodepoint()) |codepoint| {
        const glyph = ttf.codepointGlyphIndex(codepoint);
        buffer.clearRetainingCapacity();
        const dims = ttf.glyphBitmap(self.gpa, &buffer, glyph, scale, scale) catch |err| switch (err) {
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

    // Every tick.
    shader.use();
    shader.setVec3("text_color", .{ 1, 1, 1 });

    // shader.bind();
    // shader.vertex_array.bind();

    var x: f32 = position.x + -self.screen.width / 2;
    const y: f32 = position.y;
    scale = 1;
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
