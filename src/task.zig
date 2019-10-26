//  Copyright (c) 2019 emekoi
//
//  This library is free software; you can redistribute it and/or modify it
//  under the terms of the MIT license. See LICENSE for details.
//


// git-branch git symbolic-ref HEAD
pub const Task = fn () ![]const u8;

pub const AsyncTask = async fn () ![]const u8;
