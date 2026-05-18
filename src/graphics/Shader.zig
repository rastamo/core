const Self = @This();
const std = @import("std");
const gl = @import("zopengl").bindings;
const zm = @import("zmath");

id: u32,
pub fn init(io: std.Io, path_vs: []const u8, path_fs: []const u8) !Self {
    const buffer_size = 1024 * 2;
    var buffer: [buffer_size]u8 = undefined;
    var file = try std.Io.Dir.cwd().openFile(io, path_vs, .{ .mode = .read_only });
    var reader = file.reader(io, &buffer);
    var interface: *std.Io.Reader = &reader.interface;

    try interface.fillMore();

    var vs_buffer: [buffer_size]u8 = undefined;
    @memcpy(vs_buffer[0..interface.end], buffer[0..interface.end]);
    vs_buffer[interface.end] = 0;
    const vs: [*c]const u8 = &vs_buffer[0];

    file = try std.Io.Dir.cwd().openFile(io, path_fs, .{ .mode = .read_only });
    reader = file.reader(io, &buffer);
    interface = &reader.interface;

    try interface.fillMore();
    var fs_buffer: [buffer_size]u8 = undefined;
    @memcpy(fs_buffer[0..interface.end], buffer[0..interface.end]);
    fs_buffer[interface.end] = 0;
    const fs: [*c]const u8 = &fs_buffer[0];

    // Build and compile shader program.
    const vertexShader = gl.createShader(gl.VERTEX_SHADER);
    defer gl.deleteShader(vertexShader);
    gl.shaderSource(vertexShader, 1, &vs, null);
    gl.compileShader(vertexShader);

    const fragmentShader = gl.createShader(gl.FRAGMENT_SHADER);
    gl.shaderSource(fragmentShader, 1, &fs, null);
    gl.compileShader(fragmentShader);

    const self: Self = .{ .id = gl.createProgram() };
    gl.attachShader(self.id, vertexShader);
    defer gl.deleteShader(vertexShader);
    gl.attachShader(self.id, fragmentShader);
    defer gl.deleteShader(fragmentShader);
    gl.linkProgram(self.id);

    return self;
}
pub fn use(self: Self) void {
    gl.useProgram(self.id);
}

pub fn deinit(self: Self) void {
    gl.deleteProgram(self.id);
}

pub fn setInt(self: Self, name: [*c]const u8, value: i32) void {
    gl.uniform1i(gl.getUniformLocation(self.id, name), value);
}
pub fn setMat4(self: Self, name: [*c]const u8, value: [4]@Vector(4, f32)) void {
    gl.uniformMatrix4fv(gl.getUniformLocation(self.id, name), 1, gl.TRUE, &value[0][0]);
}
pub fn setVec2(self: Self, name: [*c]const u8, value: @Vector(2, f32)) void {
    gl.uniform2fv(gl.getUniformLocation(self.id, name), 1, &value[0]);
}
pub fn setVec3(self: Self, name: [*c]const u8, value: @Vector(3, f32)) void {
    gl.uniform3fv(gl.getUniformLocation(self.id, name), 1, &value[0]);
}
pub fn setFloat(self: Self, name: [*c]const u8, value: f32) void {
    gl.uniform1f(gl.getUniformLocation(self.id, name), value);
}
