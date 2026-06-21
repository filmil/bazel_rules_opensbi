"""Common compiler/linker flags for building OpenSBI, derived from its Makefile.

These mirror the flags OpenSBI's own build uses for the `generic` platform, with
one intentional difference: upstream's `-Werror` is dropped. `-Werror` is a
developer convenience that makes the build brittle against new compiler
versions, and it is not needed to produce correct firmware.
"""

# The default ISA/ABI/code-model OpenSBI selects for a 64-bit generic build.
DEFAULT_MARCH = "rv64imafdc_zicsr_zifencei"
DEFAULT_MABI = "lp64"
DEFAULT_MCMODEL = "medany"

# Compile flags that do not depend on the ISA/ABI selection. Applied to both
# C and assembler (.S) sources, exactly as OpenSBI's CFLAGS/ASFLAGS do.
_BASE_COPTS = [
    "-g",
    "-Wall",
    "-ffreestanding",
    "-nostdlib",
    "-fno-stack-protector",
    "-fno-strict-aliasing",
    "-ffunction-sections",
    "-fdata-sections",
    "-fno-omit-frame-pointer",
    "-fno-optimize-sibling-calls",
    "-mno-save-restore",
    "-mstrict-align",
    "-fPIE",
    "-O2",
]

# Linker flags (compile_elf / ELFFLAGS in the OpenSBI Makefile). The compiler
# driver performs the link, so these are driver + `-Wl,` flags.
OPENSBI_LDFLAGS = [
    "-fuse-ld=bfd",
    "-nostdlib",
    "-pie",
    "-Wl,--gc-sections",
    "-Wl,--build-id=none",
    "-Wl,--no-dynamic-linker",
    "-Wl,-pie",
]

def arch_copts(march = DEFAULT_MARCH, mabi = DEFAULT_MABI, mcmodel = DEFAULT_MCMODEL):
    """Returns the ISA/ABI/code-model compile flags.

    Args:
      march: the `-march` value (e.g. `rv64imafdc_zicsr_zifencei`).
      mabi: the `-mabi` value (e.g. `lp64`).
      mcmodel: the `-mcmodel` value (e.g. `medany`).

    Returns:
      A list of compiler flags.
    """
    return [
        "-march=" + march,
        "-mabi=" + mabi,
        "-mcmodel=" + mcmodel,
    ]

def base_copts():
    """Returns the architecture-independent OpenSBI compile flags."""
    return list(_BASE_COPTS)
