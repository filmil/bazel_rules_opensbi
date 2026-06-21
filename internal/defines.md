<!-- Generated with Stardoc: http://skydoc.bazel.build -->

Common compiler/linker flags for building OpenSBI, derived from its Makefile.

These mirror the flags OpenSBI's own build uses for the `generic` platform, with
one intentional difference: upstream's `-Werror` is dropped. `-Werror` is a
developer convenience that makes the build brittle against new compiler
versions, and it is not needed to produce correct firmware.

<a id="arch_copts"></a>

## arch_copts

<pre>
load("@rules_opensbi//internal:defines.bzl", "arch_copts")

arch_copts(<a href="#arch_copts-march">march</a>, <a href="#arch_copts-mabi">mabi</a>, <a href="#arch_copts-mcmodel">mcmodel</a>)
</pre>

Returns the ISA/ABI/code-model compile flags.

**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="arch_copts-march"></a>march |  the `-march` value (e.g. `rv64imafdc_zicsr_zifencei`).   |  `"rv64imafdc_zicsr_zifencei"` |
| <a id="arch_copts-mabi"></a>mabi |  the `-mabi` value (e.g. `lp64`).   |  `"lp64"` |
| <a id="arch_copts-mcmodel"></a>mcmodel |  the `-mcmodel` value (e.g. `medany`).   |  `"medany"` |

**RETURNS**

A list of compiler flags.


<a id="base_copts"></a>

## base_copts

<pre>
load("@rules_opensbi//internal:defines.bzl", "base_copts")

base_copts()
</pre>

Returns the architecture-independent OpenSBI compile flags.



