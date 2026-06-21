"""`opensbi_firmware`: links an OpenSBI firmware image (fw_dynamic/fw_jump/fw_payload)."""

load(":common.bzl", "TOOLCHAIN_ATTRS", "compile_source", "get_tools")
load(":defines.bzl", "DEFAULT_MABI", "DEFAULT_MARCH", "DEFAULT_MCMODEL", "OPENSBI_LDFLAGS", "arch_copts", "base_copts")
load(":providers.bzl", "OpenSbiFirmwareInfo", "OpenSbiInfo")

_FW_TYPES = ["dynamic", "jump", "payload"]

def _fw_defines(ctx):
    """Builds the FW_* preprocessor defines for the selected firmware type."""
    defines = ["FW_TEXT_START=" + ctx.attr.text_start]
    if ctx.attr.fw_type == "jump":
        defines.append("FW_JUMP_OFFSET=" + ctx.attr.jump_offset)
        defines.append("FW_JUMP_FDT_OFFSET=" + ctx.attr.jump_fdt_offset)
    if ctx.attr.fw_type == "payload":
        defines.append("FW_PAYLOAD_OFFSET=" + ctx.attr.payload_offset)
        defines.append("FW_PAYLOAD_FDT_OFFSET=" + ctx.attr.payload_fdt_offset)
        if ctx.file.payload:
            defines.append("FW_PAYLOAD_PATH=\"%s\"" % ctx.file.payload.path)
    if ctx.file.fdt:
        defines.append("FW_FDT_PATH=\"%s\"" % ctx.file.fdt.path)
    return defines + ctx.attr.defines

def _opensbi_firmware_impl(ctx):
    tools = get_tools(ctx)
    info = ctx.attr.lib[OpenSbiInfo]
    config_header = info.config_header
    include_dirs = info.include_dirs.to_list()
    hdrs = info.hdrs

    copts = base_copts() + arch_copts(ctx.attr.march, ctx.attr.mabi, ctx.attr.mcmodel) + ctx.attr.copts
    fw_defines = _fw_defines(ctx)

    # Extra files the firmware source embeds via .incbin (payload, fdt).
    embedded = []
    if ctx.file.payload:
        embedded.append(ctx.file.payload)
    if ctx.file.fdt:
        embedded.append(ctx.file.fdt)

    # 1. Compile fw_<type>.S (it #includes fw_base.S).
    fw_obj = ctx.actions.declare_file(ctx.label.name + ".o")
    obj_args = ctx.actions.args()
    obj_args.add_all(copts)
    obj_args.add_all(include_dirs, format_each = "-I%s")
    obj_args.add(ctx.file.fw_src.dirname, format = "-I%s")
    if config_header:
        obj_args.add("-include", config_header)
    obj_args.add_all(fw_defines, format_each = "-D%s")
    obj_args.add("-c", ctx.file.fw_src)
    obj_args.add("-o", fw_obj)
    obj_inputs = [ctx.file.fw_src] + embedded + ctx.files.textual_hdrs
    if config_header:
        obj_inputs.append(config_header)
    ctx.actions.run(
        executable = tools.gcc,
        arguments = [obj_args],
        inputs = depset(obj_inputs, transitive = [hdrs, tools.files]),
        outputs = [fw_obj],
        mnemonic = "OpenSbiFwCc",
        progress_message = "Compiling OpenSBI firmware %s" % ctx.label.name,
    )

    # 2. Preprocess the linker script (.elf.ldS -> .ld). -E -P avoids cpp line
    #    markers, which are not valid linker-script syntax.
    ld = ctx.actions.declare_file(ctx.label.name + ".ld")
    ld_args = ctx.actions.args()
    ld_args.add("-E")
    ld_args.add("-P")
    ld_args.add_all(include_dirs, format_each = "-I%s")
    if config_header:
        ld_args.add("-include", config_header)
    ld_args.add_all(fw_defines, format_each = "-D%s")
    ld_args.add(ctx.file.linker_script.dirname, format = "-I%s")
    ld_args.add("-x", "c")
    ld_args.add(ctx.file.linker_script)
    ld_args.add("-o", ld)
    ld_inputs = [ctx.file.linker_script] + ctx.files.textual_hdrs
    if config_header:
        ld_inputs.append(config_header)
    ctx.actions.run(
        executable = tools.gcc,
        arguments = [ld_args],
        inputs = depset(ld_inputs, transitive = [hdrs, tools.files]),
        outputs = [ld],
        mnemonic = "OpenSbiLdScript",
        progress_message = "Preprocessing linker script for %s" % ctx.label.name,
    )

    # 3. Link: driver-driven, fw object + the archive group + linker script.
    elf = ctx.actions.declare_file(ctx.label.name + ".elf")
    link_args = ctx.actions.args()
    link_args.add_all(copts)
    link_args.add(fw_obj)
    link_args.add("-Wl,--start-group")
    link_args.add_all(info.archives)
    link_args.add("-Wl,--end-group")
    link_args.add_all(OPENSBI_LDFLAGS)
    link_args.add(ld, format = "-Wl,-T%s")
    link_args.add("-o", elf)
    ctx.actions.run(
        executable = tools.gcc,
        arguments = [link_args],
        inputs = depset([fw_obj, ld], transitive = [info.archives, tools.files]),
        outputs = [elf],
        mnemonic = "OpenSbiLink",
        progress_message = "Linking OpenSBI firmware %s" % ctx.label.name,
    )

    # 4. objcopy -> raw binary, suitable for QEMU -bios.
    bin = ctx.actions.declare_file(ctx.label.name + ".bin")
    bin_args = ctx.actions.args()
    bin_args.add("-S")
    bin_args.add("-O", "binary")
    bin_args.add(elf)
    bin_args.add(bin)
    ctx.actions.run(
        executable = tools.objcopy,
        arguments = [bin_args],
        inputs = depset([elf], transitive = [tools.files]),
        outputs = [bin],
        mnemonic = "OpenSbiObjcopy",
        progress_message = "Objcopy OpenSBI firmware %s" % ctx.label.name,
    )

    return [
        DefaultInfo(files = depset([elf, bin])),
        OpenSbiFirmwareInfo(elf = elf, bin = bin, fw_type = ctx.attr.fw_type),
    ]

opensbi_firmware = rule(
    implementation = _opensbi_firmware_impl,
    doc = """Links an OpenSBI firmware image and produces both `.elf` and `.bin`.

OpenSBI ships three firmware types:

* `dynamic` (`fw_dynamic`): the next boot stage passes parameters at runtime.
* `jump`    (`fw_jump`): jumps to a fixed address for the next stage.
* `payload` (`fw_payload`): embeds the next stage binary directly.

The rule compiles the firmware's `fw_<type>.S` (which includes `fw_base.S`),
preprocesses its linker script, links against the transitive archives carried by
`lib`, and runs objcopy to emit the raw binary used with QEMU `-bios`.""",
    attrs = dict(
        TOOLCHAIN_ATTRS,
        fw_type = attr.string(
            mandatory = True,
            values = _FW_TYPES,
            doc = "Firmware type: 'dynamic', 'jump' or 'payload'.",
        ),
        fw_src = attr.label(
            mandatory = True,
            allow_single_file = [".S"],
            doc = "The firmware assembler entry source (e.g. firmware/fw_dynamic.S).",
        ),
        linker_script = attr.label(
            mandatory = True,
            allow_single_file = [".ldS"],
            doc = "The firmware linker script template (e.g. firmware/fw_dynamic.elf.ldS).",
        ),
        textual_hdrs = attr.label_list(
            allow_files = [".S", ".ldS", ".h"],
            doc = "Files textually included by the firmware source or linker script " +
                  "(e.g. firmware/fw_base.S, firmware/fw_base.ldS).",
        ),
        lib = attr.label(
            mandatory = True,
            providers = [OpenSbiInfo],
            doc = "The platform opensbi_library to link (carries libsbi + utils + platform).",
        ),
        payload = attr.label(
            allow_single_file = True,
            doc = "For fw_type='payload': the next-stage binary to embed.",
        ),
        fdt = attr.label(
            allow_single_file = [".dtb"],
            doc = "Optional flattened device tree to embed (sets FW_FDT_PATH).",
        ),
        text_start = attr.string(default = "0x0", doc = "FW_TEXT_START load address."),
        jump_offset = attr.string(default = "0x200000", doc = "FW_JUMP_OFFSET (fw_jump)."),
        jump_fdt_offset = attr.string(default = "0x2200000", doc = "FW_JUMP_FDT_OFFSET (fw_jump)."),
        payload_offset = attr.string(default = "0x200000", doc = "FW_PAYLOAD_OFFSET (fw_payload)."),
        payload_fdt_offset = attr.string(default = "0x2200000", doc = "FW_PAYLOAD_FDT_OFFSET (fw_payload)."),
        defines = attr.string_list(doc = "Extra preprocessor defines (without -D)."),
        march = attr.string(default = DEFAULT_MARCH, doc = "The -march value (must match lib)."),
        mabi = attr.string(default = DEFAULT_MABI, doc = "The -mabi value (must match lib)."),
        mcmodel = attr.string(default = DEFAULT_MCMODEL, doc = "The -mcmodel value."),
        copts = attr.string_list(doc = "Extra compile flags."),
    ),
)
