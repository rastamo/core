const std = @import("std");

pub const vulkan = struct {
    pub fn draw() void {
        std.log.info("{s} is not implemented.", .{"Vulkan"});
    }
};
