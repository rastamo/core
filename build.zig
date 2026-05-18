const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const zglfw = b.dependency("zglfw", .{
        .x11 = false,
    });
    const core = b.addModule("core", .{
        .root_source_file = b.path("src/root.zig"),
        .target = target,
        .imports = &.{
            .{ .name = "zglfw", .module = zglfw.module("root") },
            .{ .name = "zopengl", .module = b.dependency("zopengl", .{}).module("root") },
            .{ .name = "zmath", .module = b.dependency("zmath", .{}).module("root") },
        },
    });
    const exe = b.addExecutable(.{
        .name = "sandbox",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .optimize = optimize,
            .imports = &.{
                .{ .name = "core", .module = core },
                .{ .name = "zglfw", .module = zglfw.module("root") },
                .{ .name = "zopengl", .module = b.dependency("zopengl", .{}).module("root") },
                .{ .name = "zmath", .module = b.dependency("zmath", .{}).module("root") },
                .{ .name = "TrueType", .module = b.dependency("TrueType", .{}).module("TrueType") },
            },
        }),
    });
    exe.use_llvm = true;
    exe.root_module.linkLibrary(zglfw.artifact("glfw"));
    b.installArtifact(exe);

    const run_step = b.step("run", "Run the app");

    const run_cmd = b.addRunArtifact(exe);
    run_step.dependOn(&run_cmd.step);

    run_cmd.step.dependOn(b.getInstallStep());
}
