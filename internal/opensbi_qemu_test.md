<!-- Generated with Stardoc: http://skydoc.bazel.build -->

`opensbi_qemu_test`: boots a firmware image under QEMU and checks the banner.

This is an end-to-end smoke test: it runs `qemu-system-riscv64 -bios <fw.bin>`
and asserts the OpenSBI banner appears on the serial console. QEMU is hermetic
(the xPack qemu-riscv build, fetched by the `qemu` module extension and carried
in the test's runfiles), so no system QEMU is required.

<a id="opensbi_qemu_test"></a>

## opensbi_qemu_test

<pre>
load("@rules_opensbi//internal:opensbi_qemu_test.bzl", "opensbi_qemu_test")

opensbi_qemu_test(<a href="#opensbi_qemu_test-name">name</a>, <a href="#opensbi_qemu_test-expect">expect</a>, <a href="#opensbi_qemu_test-firmware">firmware</a>, <a href="#opensbi_qemu_test-machine">machine</a>, <a href="#opensbi_qemu_test-timeout_seconds">timeout_seconds</a>)
</pre>

Boots an opensbi_firmware image under the hermetic QEMU and asserts the banner prints.

**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="opensbi_qemu_test-name"></a>name |  A unique name for this target.   | <a href="https://bazel.build/concepts/labels#target-names">Name</a> | required |  |
| <a id="opensbi_qemu_test-expect"></a>expect |  Substring to require in QEMU output.   | String | optional |  `"OpenSBI"`  |
| <a id="opensbi_qemu_test-firmware"></a>firmware |  The opensbi_firmware target to boot.   | <a href="https://bazel.build/concepts/labels">Label</a> | required |  |
| <a id="opensbi_qemu_test-machine"></a>machine |  QEMU -machine value.   | String | optional |  `"virt"`  |
| <a id="opensbi_qemu_test-timeout_seconds"></a>timeout_seconds |  Seconds before QEMU is killed.   | Integer | optional |  `15`  |


