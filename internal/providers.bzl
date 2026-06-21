"""Providers shared by the OpenSBI rules."""

OpenSbiInfo = provider(
    doc = """Information propagated by `opensbi_library` to firmware and other libraries.

It carries the compiled static archive together with everything needed to
compile a dependent: the headers to expose and the include directories to pass
on the command line.""",
    fields = {
        "archives": "depset[File]: static archives (.a) to link, this target and its deps.",
        "hdrs": "depset[File]: header files needed to compile dependents.",
        "include_dirs": "depset[str]: execroot-relative -I include directories.",
        "config_header": "File: the OpenSBI autoconf.h injected with -include, or None.",
        "defines": "depset[str]: preprocessor defines (without -D) to apply to dependents.",
    },
)

OpenSbiFirmwareInfo = provider(
    doc = "Information about a built OpenSBI firmware image.",
    fields = {
        "elf": "File: the linked firmware ELF.",
        "bin": "File: the raw binary (objcopy -O binary) suitable for -bios.",
        "fw_type": "str: one of 'dynamic', 'jump', 'payload'.",
    },
)
