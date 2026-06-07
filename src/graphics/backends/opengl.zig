const zopengl = @import("zopengl");
pub const gl = zopengl.bindings;
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
    gl.enable(gl.BLEND); // PNG ALPHA
    gl.blendFunc(gl.SRC_ALPHA, gl.ONE_MINUS_SRC_ALPHA); // PNG ALPHA
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

pub fn drawElements() void {
    gl.drawElements(gl.TRIANGLES, 6, gl.UNSIGNED_INT, null);
}
