"""`dtb`: compiles a device tree source (.dts) into a flattened blob (.dtb).

The pipeline mirrors OpenSBI's: run the C preprocessor over the `.dts` (so that
`#include`d `.dtsi` fragments and `#define`s work), then feed the result to the
device tree compiler. Both tools are hermetic: the preprocessor is the toolchain
GCC, and `dtc` is the `@dtc//:dtc` binary (built from source with hermetic
flex/bison via the `dtc` Bazel module).
"""

load(":common.bzl", "get_tools")

def _dirnames(files):
    seen = {}
    for f in files:
        seen[f.dirname] = True
    return seen.keys()

def _dtb_impl(ctx):
    tools = get_tools(ctx)
    src = ctx.file.src
    includes = ctx.files.includes

    # Include directories for both the preprocessor (#include "...") and dtc
    # (/include/ "..."): the .dts directory plus any directory contributing an
    # included fragment.
    inc_dirs = depset([src.dirname] + _dirnames(includes)).to_list()

    pre = ctx.actions.declare_file(ctx.label.name + ".pre.dts")
    pre_args = ctx.actions.args()
    pre_args.add("-E")
    pre_args.add("-P")
    pre_args.add("-nostdinc")
    pre_args.add("-nostdlib")
    pre_args.add("-fno-builtin")
    pre_args.add("-D__DTS__")
    pre_args.add("-x", "assembler-with-cpp")
    pre_args.add_all(inc_dirs, format_each = "-I%s")
    pre_args.add(src)
    pre_args.add("-o", pre)
    ctx.actions.run(
        executable = tools.gcc,
        arguments = [pre_args],
        inputs = depset([src] + includes, transitive = [tools.files]),
        outputs = [pre],
        mnemonic = "DtsCpp",
        progress_message = "Preprocessing device tree %s" % src.short_path,
    )

    dtb = ctx.actions.declare_file(ctx.label.name + ".dtb")
    dtc_args = ctx.actions.args()
    dtc_args.add("-I", "dts")
    dtc_args.add("-O", "dtb")
    dtc_args.add_all(inc_dirs, before_each = "-i")
    dtc_args.add(pre)
    dtc_args.add("-o", dtb)
    ctx.actions.run(
        executable = ctx.executable._dtc,
        arguments = [dtc_args],
        inputs = depset([pre] + includes),
        outputs = [dtb],
        mnemonic = "Dtc",
        progress_message = "Compiling device tree %s" % dtb.short_path,
    )
    return [DefaultInfo(files = depset([dtb]))]

dtb = rule(
    implementation = _dtb_impl,
    doc = "Compiles a device tree source (.dts) into a flattened blob (.dtb).",
    attrs = {
        "src": attr.label(mandatory = True, allow_single_file = [".dts"], doc = "The device tree source."),
        "includes": attr.label_list(allow_files = [".dts", ".dtsi", ".h"], doc = "Included .dtsi/.h fragments."),
        "_gcc": attr.label(default = "@opensbi_riscv_toolchain//:gcc", allow_single_file = True),
        "_ar": attr.label(default = "@opensbi_riscv_toolchain//:ar", allow_single_file = True),
        "_objcopy": attr.label(default = "@opensbi_riscv_toolchain//:objcopy", allow_single_file = True),
        "_toolchain_files": attr.label(default = "@opensbi_riscv_toolchain//:all"),
        "_dtc": attr.label(
            default = "@dtc//:dtc",
            executable = True,
            cfg = "exec",
            doc = "The hermetic device tree compiler.",
        ),
    },
)
