//  Copyright (c) 2018 emekoi
//
//  This library is free software; you can redistribute it and/or modify it
//  under the terms of the MIT license. See LICENSE for details.
//

pub usingnamespace @import("prompt.zig");

usingnamespace if (@import("root") == @This())
    struct {
        const std = @import("std");

        pub fn main() void {
            const user = std.c.getenv(c"USER") orelse c"$USER";
            const len = std.mem.len(u8, user);
            const cmd = [_]Command{
                Command.Bright,
                Command{ .ForeGround = .Red },
                Command{ .ReturnCode = ReturnCode{} },
                Command{ .ForeGround = .Green },
                Command{ .Text = user[0..len] },
                Command{ .ForeGround = .Blue },
                Command{ .Text = " $(pwd)" },
                Command.Reset,
                Command{ .Text = "\n%% " },
            };

            var stdout = std.io.getStdOut() catch return;
            var stream = &stdout.outStream().stream;

            for (cmd) |c| {
                stream.print("{}", c) catch return;
            }
        }
    };
