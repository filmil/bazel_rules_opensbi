"""Helpers shared by the OpenSBI rules for driving the hermetic GCC toolchain."""

# Private attributes that wire every OpenSBI rule to the hermetic toolchain.
# The rules invoke these binaries directly via ctx.actions.run; `_toolchain_files`
# is the full toolchain tree, passed as action inputs so the GCC driver can find
# cc1/as/ld and its bundled headers relative to its own location.
TOOLCHAIN_ATTRS = {
    "_gcc": attr.label(
        default = "@opensbi_riscv_toolchain//:gcc",
        allow_single_file = True,
    ),
    "_ar": attr.label(
        default = "@opensbi_riscv_toolchain//:ar",
        allow_single_file = True,
    ),
    "_objcopy": attr.label(
        default = "@opensbi_riscv_toolchain//:objcopy",
        allow_single_file = True,
    ),
    "_toolchain_files": attr.label(
        default = "@opensbi_riscv_toolchain//:all",
    ),
}

def get_tools(ctx):
    """Returns a struct with the toolchain binaries and their input files."""
    return struct(
        gcc = ctx.file._gcc,
        ar = ctx.file._ar,
        objcopy = ctx.file._objcopy,
        files = ctx.attr._toolchain_files[DefaultInfo].files,
    )

def _join(root, d):
    return d if not root else root + "/" + d

def resolve_includes(ctx, includes):
    """Maps repo-relative include dirs to execroot-relative -I paths.

    Sources live in the module that *instantiates* the rule (the `opensbi`
    overlay), so the include roots are prefixed with that module's workspace
    root, e.g. `external/opensbi+/include`.
    """
    root = ctx.label.workspace_root
    return [_join(root, d) for d in includes]

def _obj_name(ctx, src, suffix):
    name = src.short_path
    if name.startswith("../"):
        name = name[3:]
    name = name.replace("+", "_")
    return "{}.objs/{}{}".format(ctx.label.name, name, suffix)

def compile_source(ctx, src, tools, copts, include_dirs, config_header, hdrs, defines):
    """Compiles one C or assembler (.S) source into an object file.

    Args:
      ctx: rule context.
      src: the source File (.c or .S).
      tools: result of get_tools().
      copts: list of base + arch compile flags.
      include_dirs: list of execroot-relative include directories.
      config_header: the autoconf.h File to -include, or None.
      hdrs: depset[File] of headers visible to the compile.
      defines: list of preprocessor defines (without -D).

    Returns:
      The compiled object File.
    """
    obj = ctx.actions.declare_file(_obj_name(ctx, src, ".o"))
    args = ctx.actions.args()
    args.add_all(copts)
    args.add_all(include_dirs, format_each = "-I%s")
    args.add(src.dirname, format = "-I%s")
    if config_header:
        args.add("-include", config_header)
    args.add_all(defines, format_each = "-D%s")
    args.add("-c", src)
    args.add("-o", obj)

    direct = [src]
    if config_header:
        direct.append(config_header)
    ctx.actions.run(
        executable = tools.gcc,
        arguments = [args],
        inputs = depset(direct, transitive = [hdrs, tools.files]),
        outputs = [obj],
        mnemonic = "OpenSbiCc",
        progress_message = "Compiling OpenSBI %s" % src.short_path,
    )
    return obj

def archive(ctx, objs, tools, name):
    """Archives object files into a static library (.a)."""
    lib = ctx.actions.declare_file("lib{}.a".format(name))
    args = ctx.actions.args()
    args.add("rcs")
    args.add(lib)
    args.add_all(objs)
    ctx.actions.run(
        executable = tools.ar,
        arguments = [args],
        inputs = depset(objs, transitive = [tools.files]),
        outputs = [lib],
        mnemonic = "OpenSbiAr",
        progress_message = "Archiving OpenSBI lib%s.a" % name,
    )
    return lib
