"""Top-level documentation entry point for `rules_opensbi`.

This re-exports the public rules so Stardoc can render a single overview page.
See `build/opensbi/rules.bzl` for the canonical load path used in BUILD files.
"""

load(
    "//build/opensbi:rules.bzl",
    _dtb = "dtb",
    _opensbi_firmware = "opensbi_firmware",
    _opensbi_library = "opensbi_library",
    _opensbi_qemu_test = "opensbi_qemu_test",
)

opensbi_library = _opensbi_library
opensbi_firmware = _opensbi_firmware
dtb = _dtb
opensbi_qemu_test = _opensbi_qemu_test
