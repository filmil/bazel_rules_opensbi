"""`opensbi_library`: compiles a set of OpenSBI C/asm sources into a static archive."""

load(
    ":common.bzl",
    "TOOLCHAIN_ATTRS",
    "archive",
    "compile_source",
    "get_tools",
    "resolve_includes",
)
load(":defines.bzl", "DEFAULT_MABI", "DEFAULT_MARCH", "DEFAULT_MCMODEL", "arch_copts", "base_copts")
load(":providers.bzl", "OpenSbiInfo")

def _opensbi_library_impl(ctx):
    tools = get_tools(ctx)

    # The autoconf.h config header is either supplied here or inherited from a
    # dependency, so a whole library graph shares one fixed configuration.
    config_header = ctx.file.config_header
    dep_infos = [d[OpenSbiInfo] for d in ctx.attr.deps]
    if not config_header:
        for info in dep_infos:
            if info.config_header:
                config_header = info.config_header
                break

    own_includes = resolve_includes(ctx, ctx.attr.includes)
    include_dirs = depset(
        own_includes,
        transitive = [info.include_dirs for info in dep_infos],
    ).to_list()

    hdrs = depset(
        ctx.files.hdrs,
        transitive = [info.hdrs for info in dep_infos],
    )

    defines = depset(
        ctx.attr.defines,
        transitive = [info.defines for info in dep_infos],
    ).to_list()

    copts = base_copts() + arch_copts(ctx.attr.march, ctx.attr.mabi, ctx.attr.mcmodel) + ctx.attr.copts

    objs = [
        compile_source(ctx, src, tools, copts, include_dirs, config_header, hdrs, defines)
        for src in ctx.files.srcs
    ]
    lib = archive(ctx, objs, tools, ctx.label.name)

    return [
        DefaultInfo(files = depset([lib])),
        OpenSbiInfo(
            archives = depset([lib], transitive = [info.archives for info in dep_infos]),
            hdrs = hdrs,
            include_dirs = depset(own_includes, transitive = [info.include_dirs for info in dep_infos]),
            config_header = config_header,
            defines = depset(ctx.attr.defines, transitive = [info.defines for info in dep_infos]),
        ),
    ]

opensbi_library = rule(
    implementation = _opensbi_library_impl,
    doc = """Compiles OpenSBI C and assembler sources into a static archive.

The resulting `OpenSbiInfo` carries the archive plus the headers, include
directories and config header needed to compile and link dependents. Libraries
compose: a platform library depends on the core `libsbi` and the utility
library, and a firmware links the transitive closure of archives.""",
    attrs = dict(
        TOOLCHAIN_ATTRS,
        srcs = attr.label_list(
            allow_files = [".c", ".S"],
            doc = "C and assembler sources to compile.",
        ),
        hdrs = attr.label_list(
            allow_files = True,
            doc = "Headers visible to this library and its dependents.",
        ),
        includes = attr.string_list(
            doc = "Repo-relative include directories (passed as -I to every compile).",
        ),
        defines = attr.string_list(
            doc = "Preprocessor defines (without -D) applied to this library and dependents.",
        ),
        config_header = attr.label(
            allow_single_file = True,
            doc = "OpenSBI autoconf.h to inject via -include. Inherited from deps if unset.",
        ),
        deps = attr.label_list(
            providers = [OpenSbiInfo],
            doc = "Other opensbi_library targets to build upon.",
        ),
        march = attr.string(default = DEFAULT_MARCH, doc = "The -march value."),
        mabi = attr.string(default = DEFAULT_MABI, doc = "The -mabi value."),
        mcmodel = attr.string(default = DEFAULT_MCMODEL, doc = "The -mcmodel value."),
        copts = attr.string_list(doc = "Extra compile flags appended after the defaults."),
    ),
)
