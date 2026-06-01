const std = @import("std");

const Example = struct {
    name: []const u8,
    file: []const u8,
};

const examples = [_]Example{
    .{ .name = "triangle", .file = "examples/triangle/main.zig" },
    .{ .name = "text", .file = "examples/text/main.zig" },
};

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
    core.addAnonymousImport("window_icon", .{ .root_source_file = b.path("assets/icon.png") });

    const assets = b.createModule(.{
        .root_source_file = b.path("assets/assets.zig"),
    });

    const example = b.option([]const u8, "example", "which example to build") orelse "triangle";
    var exe: ?*std.Build.Step.Compile = null;
    for (examples) |ex| {
        if (!std.mem.eql(u8, ex.name, example)) continue;

        exe = b.addExecutable(.{
            .name = ex.name,
            .root_module = b.createModule(.{
                .root_source_file = b.path(ex.file),
                .target = target,
                .optimize = optimize,
                .imports = &.{
                    .{ .name = "core", .module = core },
                    .{ .name = "assets", .module = assets },
                    .{ .name = "zglfw", .module = zglfw.module("root") },
                    .{ .name = "zopengl", .module = b.dependency("zopengl", .{}).module("root") },
                    .{ .name = "zmath", .module = b.dependency("zmath", .{}).module("root") },
                    .{ .name = "TrueType", .module = b.dependency("TrueType", .{}).module("TrueType") },
                },
            }),
        });

        exe.?.use_llvm = true;
        exe.?.root_module.linkLibrary(zglfw.artifact("glfw"));
        b.installArtifact(exe.?);

        break;
    }

    const run_cmd = b.addRunArtifact(exe.?);
    run_cmd.step.dependOn(b.getInstallStep());

    const run_step = b.step("run", "Run selected example");
    run_step.dependOn(&run_cmd.step);
}
