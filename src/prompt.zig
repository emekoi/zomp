//  Copyright (c) 2019 emekoi
//
//  This library is free software; you can redistribute it and/or modify it
//  under the terms of the MIT license. See LICENSE for details.
//

const std = @import("std");
const task = @import("task.zig");

pub const Color = enum {
    Black,
    Blue,
    Green,
    Aqua,
    Red,
    Purple,
    Yellow,
    White,

    pub fn format(
        self: Color,
        comptime fmt: []const u8,
        options: std.fmt.FormatOptions,
        context: var,
        comptime FmtError: type,
        output: fn (@typeOf(context), []const u8) FmtError!void,
    ) FmtError!void {
        if (fmt.len < 1) @compileError("invalid format specifier");
        return switch (fmt[0]) {
            'F', 'f' => switch (self) {
                .Black => std.fmt.format(context, FmtError, output, "\x1b[30m"),
                .Red => std.fmt.format(context, FmtError, output, "\x1b[31m"),
                .Green => std.fmt.format(context, FmtError, output, "\x1b[32m"),
                .Yellow => std.fmt.format(context, FmtError, output, "\x1b[33m"),
                .Blue => std.fmt.format(context, FmtError, output, "\x1b[34m"),
                .Purple => std.fmt.format(context, FmtError, output, "\x1b[35m"),
                .Aqua => std.fmt.format(context, FmtError, output, "\x1b[36m"),
                .White => std.fmt.format(context, FmtError, output, "\x1b[37m"),
            },
            'B', 'b' => switch (self) {
                .Black => std.fmt.format(context, FmtError, output, "\x1b[40m"),
                .Red => std.fmt.format(context, FmtError, output, "\x1b[41m"),
                .Green => std.fmt.format(context, FmtError, output, "\x1b[42m"),
                .Yellow => std.fmt.format(context, FmtError, output, "\x1b[43m"),
                .Blue => std.fmt.format(context, FmtError, output, "\x1b[44m"),
                .Purple => std.fmt.format(context, FmtError, output, "\x1b[45m"),
                .Aqua => std.fmt.format(context, FmtError, output, "\x1b[46m"),
                .White => std.fmt.format(context, FmtError, output, "\x1b[47m"),
            },
            else => |s| @compileError("invalid format specifier: '" ++ fmt ++ "'"),
        };
    }
};

pub const ReturnCode = struct {
    ok: []const u8 = "",
    err: []const u8 = "[%?] ",
};

pub const Command = union(enum) {
    Text: []const u8,
    ForeGround: Color,
    BackGround: Color,
    Bright,
    Underline,
    Italics,
    Reverse,
    Reset,
    ReturnCode: ReturnCode,
    HorizontalRule: u8,
    Tilde,
    AsyncTask,
    Task,

    pub fn format(
        self: Command,
        comptime fmt: []const u8,
        options: std.fmt.FormatOptions,
        context: var,
        comptime FmtError: type,
        output: fn (@typeOf(context), []const u8) FmtError!void,
    ) FmtError!void {
        return switch (self) {
            .Text => |text| std.fmt.format(context, FmtError, output, "{}", text),
            .ForeGround => |color| std.fmt.format(context, FmtError, output, "%{{{f}%}}", color),
            .BackGround => |color| std.fmt.format(context, FmtError, output, "%{{{b}%}}", color),
            .Bright => std.fmt.format(context, FmtError, output, "%{{\x1b[1m%}}"),
            .Underline => std.fmt.format(context, FmtError, output, "%{{\x1b[4m%}}"),
            .Italics => std.fmt.format(context, FmtError, output, "%{{\x1b[3m%}}"),
            .Reverse => std.fmt.format(context, FmtError, output, "%{{\x1b[7m%}}"),
            .Reset => std.fmt.format(context, FmtError, output, "%{{\x1b[0m%}}"),
            .ReturnCode => |code| std.fmt.format(context, FmtError, output, "%(?.{}.{})", code.ok, code.err),
            else => {
                return std.fmt.format(context, FmtError, output, "");
            },
        };
    }
};
