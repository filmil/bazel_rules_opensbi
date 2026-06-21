<!-- Generated with Stardoc: http://skydoc.bazel.build -->

`opensbi_library`: compiles a set of OpenSBI C/asm sources into a static archive.

<a id="opensbi_library"></a>

## opensbi_library

<pre>
load("@rules_opensbi//internal:opensbi_library.bzl", "opensbi_library")

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


