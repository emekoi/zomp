const Builder = @import("std").build.Builder;

pub fn build(b: *Builder) void {
    const mode = b.standardReleaseOptions();
    const exe = b.addExecutable("zomp", "src/zomp.zig");
    exe.linkSystemLibrary("c");
    exe.setBuildMode(mode);
    exe.install();

    const run_cmd = exe.run();
    run_cmd.step.dependOn(b.getInstallStep());

    var main_tests = b.addTest("src/zomp.zig");
    main_tests.setBuildMode(mode);

    const test_step = b.step("test", "Run library tests");
    test_step.dependOn(&main_tests.step);

    const run_step = b.step("run", "Run the executable");
    run_step.dependOn(&run_cmd.step);
}
