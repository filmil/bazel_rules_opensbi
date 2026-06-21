<!-- Generated with Stardoc: http://skydoc.bazel.build -->

Top-level documentation entry point for `rules_opensbi`.

This re-exports the public rules so Stardoc can render a single overview page.
See `build/opensbi/rules.bzl` for the canonical load path used in BUILD files.

<a id="dtb"></a>

## dtb

<pre>
load("@rules_opensbi//:doc.bzl", "dtb")

dtb(<a href="#dtb-name">name</a>, <a href="#dtb-src">src</a>, <a href="#dtb-dtc_path">dtc_path</a>, <a href="#dtb-includes">includes</a>)
</pre>

Compiles a device tree source (.dts) into a flattened blob (.dtb).

**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="dtb-name"></a>name |  A unique name for this target.   | <a href="https://bazel.build/concepts/labels#target-names">Name</a> | required |  |
| <a id="dtb-src"></a>src |  The device tree source.   | <a href="https://bazel.build/concepts/labels">Label</a> | required |  |
| <a id="dtb-dtc_path"></a>dtc_path |  Path to the device tree compiler.   | String | optional |  `"dtc"`  |
| <a id="dtb-includes"></a>includes |  Included .dtsi/.h fragments.   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional |  `[]`  |


<a id="opensbi_firmware"></a>

## opensbi_firmware

<pre>
load("@rules_opensbi//:doc.bzl", "opensbi_firmware")

opensbi_firmware(<a href="#opensbi_firmware-name">name</a>, <a href="#opensbi_firmware-copts">copts</a>, <a href="#opensbi_firmware-defines">defines</a>, <a href="#opensbi_firmware-fdt">fdt</a>, <a href="#opensbi_firmware-fw_src">fw_src</a>, <a href="#opensbi_firmware-fw_type">fw_type</a>, <a href="#opensbi_firmware-jump_fdt_offset">jump_fdt_offset</a>, <a href="#opensbi_firmware-jump_offset">jump_offset</a>, <a href="#opensbi_firmware-lib">lib</a>,
                 <a href="#opensbi_firmware-linker_script">linker_script</a>, <a href="#opensbi_firmware-mabi">mabi</a>, <a href="#opensbi_firmware-march">march</a>, <a href="#opensbi_firmware-mcmodel">mcmodel</a>, <a href="#opensbi_firmware-payload">payload</a>, <a href="#opensbi_firmware-payload_fdt_offset">payload_fdt_offset</a>, <a href="#opensbi_firmware-payload_offset">payload_offset</a>,
                 <a href="#opensbi_firmware-text_start">text_start</a>, <a href="#opensbi_firmware-textual_hdrs">textual_hdrs</a>)
</pre>

Links an OpenSBI firmware image and produces both `.elf` and `.bin`.

OpenSBI ships three firmware types:

* `dynamic` (`fw_dynamic`): the next boot stage passes parameters at runtime.
* `jump`    (`fw_jump`): jumps to a fixed address for the next stage.
* `payload` (`fw_payload`): embeds the next stage binary directly.

The rule compiles the firmware's `fw_<type>.S` (which includes `fw_base.S`),
preprocesses its linker script, links against the transitive archives carried by
`lib`, and runs objcopy to emit the raw binary used with QEMU `-bios`.

**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="opensbi_firmware-name"></a>name |  A unique name for this target.   | <a href="https://bazel.build/concepts/labels#target-names">Name</a> | required |  |
| <a id="opensbi_firmware-copts"></a>copts |  Extra compile flags.   | List of strings | optional |  `[]`  |
| <a id="opensbi_firmware-defines"></a>defines |  Extra preprocessor defines (without -D).   | List of strings | optional |  `[]`  |
| <a id="opensbi_firmware-fdt"></a>fdt |  Optional flattened device tree to embed (sets FW_FDT_PATH).   | <a href="https://bazel.build/concepts/labels">Label</a> | optional |  `None`  |
| <a id="opensbi_firmware-fw_src"></a>fw_src |  The firmware assembler entry source (e.g. firmware/fw_dynamic.S).   | <a href="https://bazel.build/concepts/labels">Label</a> | required |  |
| <a id="opensbi_firmware-fw_type"></a>fw_type |  Firmware type: 'dynamic', 'jump' or 'payload'.   | String | required |  |
| <a id="opensbi_firmware-jump_fdt_offset"></a>jump_fdt_offset |  FW_JUMP_FDT_OFFSET (fw_jump).   | String | optional |  `"0x2200000"`  |
| <a id="opensbi_firmware-jump_offset"></a>jump_offset |  FW_JUMP_OFFSET (fw_jump).   | String | optional |  `"0x200000"`  |
| <a id="opensbi_firmware-lib"></a>lib |  The platform opensbi_library to link (carries libsbi + utils + platform).   | <a href="https://bazel.build/concepts/labels">Label</a> | required |  |
| <a id="opensbi_firmware-linker_script"></a>linker_script |  The firmware linker script template (e.g. firmware/fw_dynamic.elf.ldS).   | <a href="https://bazel.build/concepts/labels">Label</a> | required |  |
| <a id="opensbi_firmware-mabi"></a>mabi |  The -mabi value (must match lib).   | String | optional |  `"lp64"`  |
| <a id="opensbi_firmware-march"></a>march |  The -march value (must match lib).   | String | optional |  `"rv64imafdc_zicsr_zifencei"`  |
| <a id="opensbi_firmware-mcmodel"></a>mcmodel |  The -mcmodel value.   | String | optional |  `"medany"`  |
| <a id="opensbi_firmware-payload"></a>payload |  For fw_type='payload': the next-stage binary to embed.   | <a href="https://bazel.build/concepts/labels">Label</a> | optional |  `None`  |
| <a id="opensbi_firmware-payload_fdt_offset"></a>payload_fdt_offset |  FW_PAYLOAD_FDT_OFFSET (fw_payload).   | String | optional |  `"0x2200000"`  |
| <a id="opensbi_firmware-payload_offset"></a>payload_offset |  FW_PAYLOAD_OFFSET (fw_payload).   | String | optional |  `"0x200000"`  |
| <a id="opensbi_firmware-text_start"></a>text_start |  FW_TEXT_START load address.   | String | optional |  `"0x0"`  |
| <a id="opensbi_firmware-textual_hdrs"></a>textual_hdrs |  Files textually included by the firmware source or linker script (e.g. firmware/fw_base.S, firmware/fw_base.ldS).   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional |  `[]`  |


<a id="opensbi_library"></a>

## opensbi_library

<pre>
load("@rules_opensbi//:doc.bzl", "opensbi_library")

opensbi_library(<a href="#opensbi_library-name">name</a>, <a href="#opensbi_library-deps">deps</a>, <a href="#opensbi_library-srcs">srcs</a>, <a href="#opensbi_library-hdrs">hdrs</a>, <a href="#opensbi_library-config_header">config_header</a>, <a href="#opensbi_library-copts">copts</a>, <a href="#opensbi_library-defines">defines</a>, <a href="#opensbi_library-includes">includes</a>, <a href="#opensbi_library-mabi">mabi</a>, <a href="#opensbi_library-march">march</a>,
                <a href="#opensbi_library-mcmodel">mcmodel</a>)
</pre>

Compiles OpenSBI C and assembler sources into a static archive.

The resulting `OpenSbiInfo` carries the archive plus the headers, include
directories and config header needed to compile and link dependents. Libraries
compose: a platform library depends on the core `libsbi` and the utility
library, and a firmware links the transitive closure of archives.

**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="opensbi_library-name"></a>name |  A unique name for this target.   | <a href="https://bazel.build/concepts/labels#target-names">Name</a> | required |  |
| <a id="opensbi_library-deps"></a>deps |  Other opensbi_library targets to build upon.   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional |  `[]`  |
| <a id="opensbi_library-srcs"></a>srcs |  C and assembler sources to compile.   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional |  `[]`  |
| <a id="opensbi_library-hdrs"></a>hdrs |  Headers visible to this library and its dependents.   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional |  `[]`  |
| <a id="opensbi_library-config_header"></a>config_header |  OpenSBI autoconf.h to inject via -include. Inherited from deps if unset.   | <a href="https://bazel.build/concepts/labels">Label</a> | optional |  `None`  |
| <a id="opensbi_library-copts"></a>copts |  Extra compile flags appended after the defaults.   | List of strings | optional |  `[]`  |
| <a id="opensbi_library-defines"></a>defines |  Preprocessor defines (without -D) applied to this library and dependents.   | List of strings | optional |  `[]`  |
| <a id="opensbi_library-includes"></a>includes |  Repo-relative include directories (passed as -I to every compile).   | List of strings | optional |  `[]`  |
| <a id="opensbi_library-mabi"></a>mabi |  The -mabi value.   | String | optional |  `"lp64"`  |
| <a id="opensbi_library-march"></a>march |  The -march value.   | String | optional |  `"rv64imafdc_zicsr_zifencei"`  |
| <a id="opensbi_library-mcmodel"></a>mcmodel |  The -mcmodel value.   | String | optional |  `"medany"`  |


<a id="opensbi_qemu_test"></a>

## opensbi_qemu_test

<pre>
load("@rules_opensbi//:doc.bzl", "opensbi_qemu_test")

opensbi_qemu_test(<a href="#opensbi_qemu_test-name">name</a>, <a href="#opensbi_qemu_test-expect">expect</a>, <a href="#opensbi_qemu_test-firmware">firmware</a>, <a href="#opensbi_qemu_test-machine">machine</a>, <a href="#opensbi_qemu_test-qemu_path">qemu_path</a>, <a href="#opensbi_qemu_test-timeout_seconds">timeout_seconds</a>)
</pre>

Boots an opensbi_firmware image under QEMU and asserts the banner prints.

**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="opensbi_qemu_test-name"></a>name |  A unique name for this target.   | <a href="https://bazel.build/concepts/labels#target-names">Name</a> | required |  |
| <a id="opensbi_qemu_test-expect"></a>expect |  Substring to require in QEMU output.   | String | optional |  `"OpenSBI"`  |
| <a id="opensbi_qemu_test-firmware"></a>firmware |  The opensbi_firmware target to boot.   | <a href="https://bazel.build/concepts/labels">Label</a> | required |  |
| <a id="opensbi_qemu_test-machine"></a>machine |  QEMU -machine value.   | String | optional |  `"virt"`  |
| <a id="opensbi_qemu_test-qemu_path"></a>qemu_path |  Path to the QEMU binary.   | String | optional |  `"qemu-system-riscv64"`  |
| <a id="opensbi_qemu_test-timeout_seconds"></a>timeout_seconds |  Seconds before QEMU is killed.   | Integer | optional |  `15`  |


