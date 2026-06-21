# bazel_rules_opensbi: Bazel-native OpenSBI for RISC-V

[![Test](https://github.com/filmil/bazel_rules_opensbi/actions/workflows/test.yml/badge.svg)](https://github.com/filmil/bazel_rules_opensbi/actions/workflows/test.yml)
[![Publish to my Bazel registry](https://github.com/filmil/bazel_rules_opensbi/actions/workflows/publish.yml/badge.svg)](https://github.com/filmil/bazel_rules_opensbi/actions/workflows/publish.yml)
[![Publish on Bazel Central Registry](https://github.com/filmil/bazel_rules_opensbi/actions/workflows/publish-bcr.yml/badge.svg)](https://github.com/filmil/bazel_rules_opensbi/actions/workflows/publish-bcr.yml)
[![Tag and Release](https://github.com/filmil/bazel_rules_opensbi/actions/workflows/tag-and-release.yml/badge.svg)](https://github.com/filmil/bazel_rules_opensbi/actions/workflows/tag-and-release.yml)

## Overview

`bazel_rules_opensbi` builds [OpenSBI](https://github.com/riscv-software-src/opensbi)
— the RISC-V Supervisor Binary Interface reference firmware — **natively with
Bazel**. Every compile, link, linker-script preprocessing, and `objcopy` step is
an ordinary Bazel action; there is no `make`, `Kconfig`, or `configure` in the
build graph.

The rules drive a **hermetic** RISC-V GCC toolchain that Bazel downloads for you,
so a clean checkout can produce bootable `fw_dynamic` / `fw_jump` / `fw_payload`
images with a single `bazel build`.

This project follows the "strict overlay" approach: it never forks or vendors
OpenSBI. The pristine upstream source is consumed unchanged and Bazel `BUILD`
files are *overlaid* on top of it. There are two published artifacts:

* **`rules_opensbi`** — this repository (the rules).
* **`opensbi`** — an overlay module providing the OpenSBI sources with `BUILD`
  files that call these rules.

## Quick start

```starlark
# MODULE.bazel
bazel_dep(name = "rules_opensbi", version = "0.0.0")
bazel_dep(name = "opensbi", version = "1.6")
```

```starlark
# BUILD.bazel — reuse a prebuilt image, or build your own.
load("@rules_opensbi//build/opensbi:rules.bzl", "opensbi_firmware", "opensbi_qemu_test")

# The opensbi module already exposes @opensbi//:fw_dynamic, @opensbi//:fw_jump,
# and the @opensbi//:generic platform library you can re-link against:
opensbi_firmware(
    name = "my_fw",
    fw_type = "payload",
    fw_src = "@opensbi//:firmware/fw_payload.S",
    linker_script = "@opensbi//:firmware/fw_payload.elf.ldS",
    textual_hdrs = [
        "@opensbi//:firmware/fw_base.S",
        "@opensbi//:firmware/fw_base.ldS",
    ],
    lib = "@opensbi//:generic",
    payload = "//path/to:my_kernel.bin",
)

opensbi_qemu_test(
    name = "my_fw_boot_test",
    firmware = ":my_fw",
)
```

```sh
bazel build @opensbi//:fw_dynamic      # -> fw_dynamic.elf and fw_dynamic.bin
bazel test  //...                      # boots images under QEMU
```

## Documentation

| File | Documentation | Description |
| :--- | :--- | :--- |
| `build/opensbi/rules.bzl` | [build/opensbi/rules.md](build/opensbi/rules.md) | Public API: load the rules from here |
| `doc.bzl` | [doc.md](doc.md) | Top-level overview of the rules |
| `internal/opensbi_library.bzl` | [internal/opensbi_library.md](internal/opensbi_library.md) | `opensbi_library`: compile sources into a static archive |
| `internal/opensbi_firmware.bzl` | [internal/opensbi_firmware.md](internal/opensbi_firmware.md) | `opensbi_firmware`: link a firmware image (ELF + bin) |
| `internal/dtb.bzl` | [internal/dtb.md](internal/dtb.md) | `dtb`: compile a device tree (`.dts` → `.dtb`) |
| `internal/opensbi_qemu_test.bzl` | [internal/opensbi_qemu_test.md](internal/opensbi_qemu_test.md) | `opensbi_qemu_test`: boot under QEMU and check the banner |
| `internal/providers.bzl` | [internal/providers.md](internal/providers.md) | Providers (`OpenSbiInfo`, `OpenSbiFirmwareInfo`) |
| `internal/defines.bzl` | [internal/defines.md](internal/defines.md) | Default ISA/ABI and shared compile/link flags |

## Examples

The [`integration/`](integration) module is a self-contained Bazel module that
consumes these rules and contains 15 worked examples:

* Device trees — [`integration/examples/devicetree`](integration/examples/devicetree):
  a single `.dts`, a board composed from `#include`d `.dtsi` fragments,
  preprocessor `#define`s in values, dtc's own `/include/`, and a `virt`-like
  tree embedded into firmware.
* Firmware & inclusion — [`integration/examples/firmware`](integration/examples/firmware):
  consuming the prebuilt `fw_dynamic`/`fw_jump`, re-linking with a fixed
  `FW_TEXT_START`, `fw_payload` embedding a next-stage binary, embedding a
  device tree, and a QEMU boot smoke test per image.

```sh
cd integration
bazel build //...
bazel test  //...   # builds dtbs and boots images; dtc and QEMU are hermetic
```

## How it works

* **Hermetic toolchain.** A module extension downloads the kernel.org
  `riscv64-linux` GCC cross toolchain. OpenSBI requires a linker that can
  produce position-independent executables (`-pie`), which bare-metal `*-elf`
  toolchains generally cannot; the Linux-targeted toolchain can, and since
  OpenSBI links `-nostdlib` no libc is involved. The `-march`/`-mabi` is chosen
  per target (default `rv64imafdc_zicsr_zifencei` / `lp64`).
* **Fixed configuration.** Instead of running Kconfig at build time, the
  `opensbi` overlay commits the generated `autoconf.h` and the `*.carray.c`
  driver-registration tables for the upstream `generic` defconfig. This keeps
  the build free of configuration scripts.
* **Hermetic `dtc` and QEMU.** The `dtb` rule uses `@dtc//:dtc` (the `dtc` Bazel
  module, built from source with hermetic flex/bison), and `opensbi_qemu_test`
  uses the relocatable xPack `qemu-system-riscv64` fetched by a module extension
  and carried in the test's runfiles. No system packages are required — a clean
  machine with only Bazel can build and boot-test the firmware.

## Registries

This module is published both to the
[Bazel Central Registry](https://registry.bazel.build) and to a personal
overlay registry. To use the personal registry, add to your `.bazelrc`:

```
common --registry=https://bcr.bazel.build
common --registry=https://raw.githubusercontent.com/filmil/bazel-registry/main
```

## Contributing

Contributions are welcome — please open an issue or pull request. Run
`bazel run //:buildifier` to format, and `bazel run //:update` to regenerate the
documentation before submitting.

## License

`bazel_rules_opensbi` is licensed under the Apache License 2.0 (see
[LICENSE](LICENSE)). OpenSBI itself is BSD-2-Clause and is **not** redistributed
by this repository; it is fetched from upstream at build time.
