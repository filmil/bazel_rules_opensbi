<!-- Generated with Stardoc: http://skydoc.bazel.build -->

Providers shared by the OpenSBI rules.

<a id="OpenSbiFirmwareInfo"></a>

## OpenSbiFirmwareInfo

<pre>
load("@rules_opensbi//internal:providers.bzl", "OpenSbiFirmwareInfo")

OpenSbiFirmwareInfo(<a href="#OpenSbiFirmwareInfo-elf">elf</a>, <a href="#OpenSbiFirmwareInfo-bin">bin</a>, <a href="#OpenSbiFirmwareInfo-fw_type">fw_type</a>)
</pre>

Information about a built OpenSBI firmware image.

**FIELDS**

| Name  | Description |
| :------------- | :------------- |
| <a id="OpenSbiFirmwareInfo-elf"></a>elf |  File: the linked firmware ELF.    |
| <a id="OpenSbiFirmwareInfo-bin"></a>bin |  File: the raw binary (objcopy -O binary) suitable for -bios.    |
| <a id="OpenSbiFirmwareInfo-fw_type"></a>fw_type |  str: one of 'dynamic', 'jump', 'payload'.    |


<a id="OpenSbiInfo"></a>

## OpenSbiInfo

<pre>
load("@rules_opensbi//internal:providers.bzl", "OpenSbiInfo")

OpenSbiInfo(<a href="#OpenSbiInfo-archives">archives</a>, <a href="#OpenSbiInfo-hdrs">hdrs</a>, <a href="#OpenSbiInfo-include_dirs">include_dirs</a>, <a href="#OpenSbiInfo-config_header">config_header</a>, <a href="#OpenSbiInfo-defines">defines</a>)
</pre>

Information propagated by `opensbi_library` to firmware and other libraries.

It carries the compiled static archive together with everything needed to
compile a dependent: the headers to expose and the include directories to pass
on the command line.

**FIELDS**

| Name  | Description |
| :------------- | :------------- |
| <a id="OpenSbiInfo-archives"></a>archives |  depset[File]: static archives (.a) to link, this target and its deps.    |
| <a id="OpenSbiInfo-hdrs"></a>hdrs |  depset[File]: header files needed to compile dependents.    |
| <a id="OpenSbiInfo-include_dirs"></a>include_dirs |  depset[str]: execroot-relative -I include directories.    |
| <a id="OpenSbiInfo-config_header"></a>config_header |  File: the OpenSBI autoconf.h injected with -include, or None.    |
| <a id="OpenSbiInfo-defines"></a>defines |  depset[str]: preprocessor defines (without -D) to apply to dependents.    |


