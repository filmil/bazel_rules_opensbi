"""Module extension that fetches a hermetic RISC-V GCC toolchain.

OpenSBI is freestanding (built with `-nostdlib`) but, since v1.x, it requires a
linker that can produce position-independent executables (`-pie`): the firmware
relocates itself to its runtime load address. Bare-metal `*-elf` toolchains
generally cannot link PIEs, so this uses the kernel.org `riscv64-linux` "nolibc"
cross toolchain (maintained by Arnd Bergmann): a modern, relocatable GCC whose
`ld` supports `-pie`. No libc is linked (`-nostdlib`), so the Linux target is
immaterial; the concrete `-march`/`-mabi` is selected per target by the rules.
"""

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

# Pinned kernel.org crosstool release (Linux x86_64 host -> riscv64-linux).
_GCC_VERSION = "13.2.0"
_URL = "https://mirrors.edge.kernel.org/pub/tools/crosstool/files/bin/x86_64/{v}/x86_64-gcc-{v}-nolibc-riscv64-linux.tar.xz".format(v = _GCC_VERSION)
_INTEGRITY = "sha256-B8WPRVHmNsvouhZweQnpSsJi9F3I/igDQBGEK9wMdBc="
_STRIP_PREFIX = "gcc-{v}-nolibc/riscv64-linux".format(v = _GCC_VERSION)

# BUILD file overlaid onto the toolchain archive. ``all`` is the complete tree,
# used as action inputs so the GCC driver can find cc1/as/ld and its bundled
# headers relative to its own location. The ``tool`` filegroups name the driver
# binaries the OpenSBI rules invoke directly.
_BUILD_FILE = """\
package(default_visibility = ["//visibility:public"])

filegroup(
    name = "all",
    srcs = glob(["**"], exclude = ["**/*.html", "**/*.pdf"]),
)

filegroup(name = "gcc", srcs = ["bin/riscv64-linux-gcc"])

filegroup(name = "ar", srcs = ["bin/riscv64-linux-ar"])

filegroup(name = "objcopy", srcs = ["bin/riscv64-linux-objcopy"])

filegroup(name = "objdump", srcs = ["bin/riscv64-linux-objdump"])

filegroup(name = "readelf", srcs = ["bin/riscv64-linux-readelf"])
"""

def _riscv_toolchain_impl(module_ctx):
    http_archive(
        name = "opensbi_riscv_toolchain",
        url = _URL,
        integrity = _INTEGRITY,
        strip_prefix = _STRIP_PREFIX,
        build_file_content = _BUILD_FILE,
    )
    return module_ctx.extension_metadata(reproducible = True)

riscv_toolchain = module_extension(
    implementation = _riscv_toolchain_impl,
    doc = "Fetches the pinned kernel.org riscv64-linux GCC toolchain.",
)
