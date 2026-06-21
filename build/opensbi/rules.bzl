"""Public API for `rules_opensbi`.

Load the OpenSBI build rules from here:

```starlark
load("@rules_opensbi//build/opensbi:rules.bzl",
     "opensbi_library", "opensbi_firmware", "dtb", "opensbi_qemu_test")
```

* `opensbi_library` compiles OpenSBI sources into a static archive.
* `opensbi_firmware` links a firmware image (`fw_dynamic`/`fw_jump`/`fw_payload`).
* `dtb` compiles a device tree (`.dts`) into a flattened blob (`.dtb`).
* `opensbi_qemu_test` boots a firmware under QEMU and checks the banner.
"""

load("//internal:defines.bzl", _DEFAULT_MABI = "DEFAULT_MABI", _DEFAULT_MARCH = "DEFAULT_MARCH", _DEFAULT_MCMODEL = "DEFAULT_MCMODEL")
load("//internal:dtb.bzl", _dtb = "dtb")
load("//internal:opensbi_firmware.bzl", _opensbi_firmware = "opensbi_firmware")
load("//internal:opensbi_library.bzl", _opensbi_library = "opensbi_library")
load("//internal:opensbi_qemu_test.bzl", _opensbi_qemu_test = "opensbi_qemu_test")
load("//internal:providers.bzl", _OpenSbiFirmwareInfo = "OpenSbiFirmwareInfo", _OpenSbiInfo = "OpenSbiInfo")

opensbi_library = _opensbi_library
opensbi_firmware = _opensbi_firmware
dtb = _dtb
opensbi_qemu_test = _opensbi_qemu_test

OpenSbiInfo = _OpenSbiInfo
OpenSbiFirmwareInfo = _OpenSbiFirmwareInfo

# Convenience re-exports of the default ISA/ABI selection.
DEFAULT_MARCH = _DEFAULT_MARCH
DEFAULT_MABI = _DEFAULT_MABI
DEFAULT_MCMODEL = _DEFAULT_MCMODEL
