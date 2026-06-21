"""`opensbi_qemu_test`: boots a firmware image under QEMU and checks the banner.

This is an end-to-end smoke test: it runs `qemu-system-riscv64 -bios <fw.bin>`
and asserts the OpenSBI banner appears on the serial console. QEMU is hermetic
(the xPack qemu-riscv build, fetched by the `qemu` module extension and carried
in the test's runfiles), so no system QEMU is required.
"""

load(":providers.bzl", "OpenSbiFirmwareInfo")

_SCRIPT = """#!/usr/bin/env bash
set -uo pipefail
BIN="{bin}"
QEMU="{qemu}"
OUT="$(mktemp)"
echo "+ ${{QEMU}} -machine {machine} -bios ${{BIN}}"
timeout -s KILL {timeout} "${{QEMU}}" -machine {machine} -smp 1 -m 128M \\
    -nographic -no-reboot -bios "${{BIN}}" >"${{OUT}}" 2>&1
echo "----- QEMU output -----"
cat "${{OUT}}"
echo "-----------------------"
if grep -q "{needle}" "${{OUT}}"; then
    echo "PASS: OpenSBI banner found"
    exit 0
fi
echo "FAIL: expected '{needle}' in QEMU output"
exit 1
"""

def _opensbi_qemu_test_impl(ctx):
    fw = ctx.attr.firmware[OpenSbiFirmwareInfo]
    bin = fw.bin
    script = ctx.actions.declare_file(ctx.label.name + ".sh")
    ctx.actions.write(
        output = script,
        content = _SCRIPT.format(
            bin = bin.short_path,
            qemu = ctx.file._qemu.short_path,
            machine = ctx.attr.machine,
            timeout = ctx.attr.timeout_seconds,
            needle = ctx.attr.expect,
        ),
        is_executable = True,
    )
    return [DefaultInfo(
        executable = script,
        runfiles = ctx.runfiles(files = [bin] + ctx.files._qemu_files),
    )]

opensbi_qemu_test = rule(
    implementation = _opensbi_qemu_test_impl,
    test = True,
    doc = "Boots an opensbi_firmware image under the hermetic QEMU and asserts the banner prints.",
    attrs = {
        "firmware": attr.label(
            mandatory = True,
            providers = [OpenSbiFirmwareInfo],
            doc = "The opensbi_firmware target to boot.",
        ),
        "machine": attr.string(default = "virt", doc = "QEMU -machine value."),
        "expect": attr.string(default = "OpenSBI", doc = "Substring to require in QEMU output."),
        "timeout_seconds": attr.int(default = 15, doc = "Seconds before QEMU is killed."),
        "_qemu": attr.label(
            default = "@opensbi_qemu//:qemu_bin",
            allow_single_file = True,
            doc = "The hermetic qemu-system-riscv64 binary.",
        ),
        "_qemu_files": attr.label(
            default = "@opensbi_qemu//:all",
            doc = "The full QEMU tree (carried in runfiles for the binary's rpath).",
        ),
    },
)
