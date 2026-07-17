const Self = @This();
const std = @import("std");
const gl = @import("zopengl").bindings;
const zm = @import("zmath");

const texture_vs = @embedFile("shaders/texture.vs");
const texture_fs = @embedFile("shaders/texture.fs");

pub const ShaderError = error{
    VertexShaderCreationFailed,
    FragmentShaderCreationFailed,
    VertexShaderCompilationFailed,
    FragmentShaderCompilationFailed,
    ProgramCreationFailed,
    ProgramLinkingFailed,
    OpenGLError,
};

id: u32,

pub fn init() !Self {
    const vs: [*c]const u8 = &texture_vs[0];
    const fs: [*c]const u8 = &texture_fs[0];

    // Build and compile shader program.
    const self: Self = .{ .id = gl.createProgram() };
    if (self.id == 0) {
        return ShaderError.ProgramCreationFailed;
    }

    // Vertex shader.
    const vertex_shader = gl.createShader(gl.VERTEX_SHADER);
    defer gl.deleteShader(vertex_shader);
    if (vertex_shader == 0) {
        return ShaderError.VertexShaderCreationFailed;
    }
    gl.shaderSource(vertex_shader, 1, &vs, null);
    gl.compileShader(vertex_shader);
    var vs_success: i32 = 0;
    gl.getShaderiv(vertex_shader, gl.COMPILE_STATUS, &vs_success);
    if (vs_success == 0) {
        var info_log: [512]u8 = undefined;
        gl.getShaderInfoLog(vertex_shader, 512, null, @ptrCast(&info_log));
        std.log.err("Vertex shader compilation failed: {s} \n", .{info_log});
        return ShaderError.VertexShaderCompilationFailed;
    }
    gl.attachShader(self.id, vertex_shader);

    // Fragment shader.
    const fragment_shader = gl.createShader(gl.FRAGMENT_SHADER);
    defer gl.deleteShader(fragment_shader);
    if (fragment_shader == 0) {
        return ShaderError.FragmentShaderCreationFailed;
    }
    gl.shaderSource(fragment_shader, 1, &fs, null);
    gl.compileShader(fragment_shader);
    var fs_success: i32 = 0;
    gl.getShaderiv(fragment_shader, gl.COMPILE_STATUS, &fs_success);
    if (fs_success == 0) {
        var info_log: [512]u8 = undefined;
        gl.getShaderInfoLog(fragment_shader, 512, null, @ptrCast(&info_log));
        std.log.err("Fragment shader compilation failed: {s} \n", .{info_log});
        return ShaderError.FragmentShaderCompilationFailed;
    }
    gl.attachShader(self.id, fragment_shader);

    // Link program.
    gl.linkProgram(self.id);
    var link_success: i32 = 0;
    gl.getProgramiv(self.id, gl.LINK_STATUS, &link_success);
    if (link_success == 0) {
        var info_log: [512]u8 = undefined;
        gl.getShaderInfoLog(self.id, 512, null, @ptrCast(&info_log));
        std.log.err("Shader program linking failed: {s} \n", .{info_log});
        return ShaderError.ProgramLinkingFailed;
    }
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
    gl.uniformMatrix4fv(gl.getUniformLocation(self.id, name), 1, gl.FALSE, &value[0][0]);
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
