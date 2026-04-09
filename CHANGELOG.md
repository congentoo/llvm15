# Changelog

## 2026-04-08: Widen PYTHON_COMPAT to 3.14 across all ebuilds

All 17 ebuilds with PYTHON_COMPAT now support python3_{10..14}.

Previously: 12 ebuilds at 3_{10..11}, 5 at 3_{10..13}.

### Analysis

- **Build-time-only** (python-any-r1, 10 ebuilds): libclc, lld, openmp,
  libcxx, libcxxabi, libunwind, compiler-rt (×3), compiler-rt-sanitizers,
  llvm-ocaml. Python used only for cmake/lit build scripts — safe to widen.
- **Runtime** (python-single-r1/python-r1, 2 ebuilds):
  - lldb: SWIG bindings, dep dev-python/six supports 3_{11..14}
  - dev-python/clang: pure ctypes wrapper around libclang.so, no
    version-sensitive code
- **Already at 3.13** (5 ebuilds): llvm, clang, IGC, lit, compiler-rt
  base — widened from 3_{10..13} to 3_{10..14}

All Python dependencies in the Gentoo tree (six, psutil, recommonmark,
sphinx) support 3.14.

## 2026-04-08: Bump intel-compute-runtime to 24.35.30872.45

9 commits since .36 (legacy maintenance branch):
- GCC 15 `<cstdint>` fixes merged upstream (3 commits)
- Type size reduction for TagAllocator
- snprintf safety for string null termination
- DRM test improvements
- Compiler warning suppression for known GCC issues

The overlay's GCC 15 patch (from Arch Linux / Daniel Bermond) is no
longer needed — all hunks detected as "already applied" in .45.

Source: https://github.com/intel/compute-runtime/compare/24.35.30872.36...24.35.30872.45

## 2026-04-08: Bump spirv-llvm-translator 15.0.22, opencl-clang 15.0.8

### spirv-llvm-translator 15.0.19 -> 15.0.22

16 backported commits from Khronos upstream (Jan-Mar 2026):
- New SPIR-V extensions: SPV_KHR_fma, SPV_INTEL_device_barrier,
  SPV_INTEL_subgroup_matrix_multiply_accumulate (FP4/FP8)
- BFloat16 demangling and type fixes
- Unsigned parameter type corrections for builtin translations
- Zero-length array handling fix
- CI improvements

Ebuild: No changes needed. The `%triple` sed fix (PR #2555) is still
required — verified `%triple` still present in test/DebugInfo/X86/*.ll.

Source: https://github.com/KhronosGroup/SPIRV-LLVM-Translator/compare/v15.0.19...v15.0.22

### opencl-clang 15.0.5 -> 15.0.8

7 commits from Intel upstream (Jan-Mar 2026):
- Support `-spirv-ext=` flag for specifying allowed SPIR-V extensions
- Clang patches: cl_khr_gl_msaa_sharing minimum version,
  pointer-to-vector conversion diagnostics
- GCC 15 compatibility: `<cstdint>` includes via LLVM patches
- SPIRV-LLVM-Translator header path fix for out-of-tree builds
- New `LLVMSPIRVLib/LLVMSPIRVOpts.h` include (headers verified present)

Ebuild: No changes needed. Old clang_library_dir.patch still applies
(offset 6 lines). CMakeLists.txt changes only affect in-tree LLVM build
path, not Gentoo's prebuilt/system LLVM path.

Source: https://github.com/intel/opencl-clang/compare/v15.0.5...v15.0.8

### Verification performed

- Downloaded and extracted both tarballs
- Confirmed `%triple` still in spirv-llvm-translator test files
- Confirmed clang_library_dir.patch applies cleanly to opencl-clang 15.0.8
- Verified `LLVMSPIRVLib/LLVMSPIRVOpts.h` exists at expected install path
- Confirmed tarball directory names match ebuild S variables

## 2026-04-08: Add Intel legacy OpenCL stack packages

Moved from localrepo overlay to consolidate the entire LLVM 15 +
Intel GPU OpenCL stack into a single overlay:

- dev-libs/intel-compute-runtime 24.35.30872.{32,36} (SLOT=legacy)
- dev-libs/opencl-clang 15.0.5 (SLOT=15)
- dev-util/intel-graphics-compiler 1.0.17791.18 (SLOT=legacy)
- dev-util/spirv-llvm-translator 15.0.{17,19} (SLOT=15)

### Patches carried

- intel-compute-runtime: GCC 15 `<cstdint>` fix (from Daniel Bermond,
  Arch Linux)
- intel-graphics-compiler: no -Werror, opencl-clang version detection
  workaround (Gentoo bug #739138), git command removal
- opencl-clang: clang library directory path fix

## 2026-04-08: Initial

LLVM 15 core toolchain ebuilds preserved from Gentoo main tree
before removal. 30+ packages across llvm-core/, llvm-runtimes/,
dev-python/, dev-ml/ categories.

All ebuilds derived from the last Gentoo tree versions, with
Gentoo patchsets (llvm r7, clang r3, openmp r6, etc.) for
GCC 13/14/15 and Python 3.12/3.13 compatibility.
