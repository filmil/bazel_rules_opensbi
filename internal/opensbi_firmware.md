<!-- Generated with Stardoc: http://skydoc.bazel.build -->

`opensbi_firmware`: links an OpenSBI firmware image (fw_dynamic/fw_jump/fw_payload).

<a id="opensbi_firmware"></a>

## opensbi_firmware

<pre>
load("@rules_opensbi//internal:opensbi_firmware.bzl", "opensbi_firmware")

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


