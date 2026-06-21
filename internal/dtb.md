<!-- Generated with Stardoc: http://skydoc.bazel.build -->

`dtb`: compiles a device tree source (.dts) into a flattened blob (.dtb).

The pipeline mirrors OpenSBI's: run the C preprocessor over the `.dts` (so that
`#include`d `.dtsi` fragments and `#define`s work), then feed the result to the
device tree compiler. Both tools are hermetic: the preprocessor is the toolchain
GCC, and `dtc` is the `@dtc//:dtc` binary (built from source with hermetic
flex/bison via the `dtc` Bazel module).

<a id="dtb"></a>

## dtb

<pre>
load("@rules_opensbi//internal:dtb.bzl", "dtb")

dtb(<a href="#dtb-name">name</a>, <a href="#dtb-src">src</a>, <a href="#dtb-includes">includes</a>)
</pre>

Compiles a device tree source (.dts) into a flattened blob (.dtb).

**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="dtb-name"></a>name |  A unique name for this target.   | <a href="https://bazel.build/concepts/labels#target-names">Name</a> | required |  |
| <a id="dtb-src"></a>src |  The device tree source.   | <a href="https://bazel.build/concepts/labels">Label</a> | required |  |
| <a id="dtb-includes"></a>includes |  Included .dtsi/.h fragments.   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional |  `[]`  |


