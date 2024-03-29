//  Copyright (c) 2018 emekoi
//
//  This library is free software; you can redistribute it and/or modify it
//  under the terms of the MIT license. See LICENSE for details.
//

pub usingnamespace @import("prompt.zig");

usingnamespace if (@import("root") == @This())
    struct {
        const std = @import("std");
        const builtin = @import("builtin");

        const mem = std.mem;
        const ascii = std.ascii;

        const Allocator = mem.Allocator;
        const Stream = std.fs.File.OutStream.Stream;

        fn flushCmds(stream: *Stream, cmds: []const Command) void {
            for (cmds) |c|
                stream.print("{}", c) catch return;
        }

        fn toUnixPath(path: []u8) []u8 {
            path[1] = ascii.toLower(path[0]);
            path[0] = '/';
            for (path) |*c| {
                switch (c.*) {
                    '\\' => c.* = '/',
                    else => {},
                }
            }

            return mem.trimRight(u8, path, "/");
        }

        fn trimWhileLeft(slice: []u8, strip: []const u8) usize {
            var idx: usize = 0;
            while (idx < slice.len and slice[idx] == strip[idx]) : (idx += 1) {}
            return idx;
        }

        fn truncatePath(allocator: *Allocator, path: []u8, home: []const u8) []const u8 {
            if (mem.startsWith(u8, path, home)) {
                path[home.len - 1] = '~';
                path = path[home.len - 1 ..];
            } else {
                path = path[trimWhileLeft(path, home) - 1 ..];
                path[0] = '/';
            }

            std.debug.warn("-> {}\n", path);

            const end = mem.indexOf(u8, path, "/") orelse 0;

            var start = mem.lastIndexOf(u8, path[0..], "/") orelse 0;
            start = mem.lastIndexOf(u8, path[0..start], "/") orelse start;

            if (end == 0) {
                return mem.join(allocator, "...", [_][]const u8{ "", path[start..] }) catch path;
            } else {
                return mem.join(allocator, "...", [_][]const u8{ path[0..end + 1], path[start..] }) catch path;
            }

            // std.debug.warn("-> {}\n", path[start..]);

            // if (path[start..].len > 1 and path[0..end].len > 0) {
            //     return mem.join(allocator, "..", [_][]u8{ path[0..end], path[start..] }) catch path;
            // } else if (path[start..].len > 1) {
            //     return path[start..];
            // } else {
            //     return path;
            // }
        }

        pub fn main() void {
            var buffer: [std.fs.MAX_PATH_BYTES]u8 = undefined;
            var allocator = &std.heap.FixedBufferAllocator.init(buffer[0..]).allocator;

            const user = mem.toSliceConst(u8, std.c.getenv(c"USER") orelse c"$USER");

            const home = blk: {
                var home = mem.toSlice(u8, std.c.getenv(c"HOME") orelse break :blk "");
                if (builtin.os == .windows)
                    break :blk toUnixPath(home);
                break :blk home;
            };

            const cwd = blk: {
                var cwd = toUnixPath(std.process.getCwdAlloc(allocator) catch break :blk "$(pwd)"[0..]);
                if (builtin.os == .windows)
                    break :blk truncatePath(allocator, cwd, home);
                break :blk cwd;
            };

            // std.debug.warn("");

            var stdout = std.io.getStdOut() catch return;
            var stream = &stdout.outStream().stream;
            flushCmds(stream, [_]Command{
                Command.Bright,
                Command{ .ForeGround = .Red },
                Command{ .ReturnCode = ReturnCode{} },
                Command{ .ForeGround = .Green },
                Command{ .Text = user },
                Command{ .ForeGround = .Blue },
                Command{ .Text = " " },
                Command{ .Text = cwd },
                Command.Reset,
                Command{ .Text = "\n%% " },
            });
        }
    };
