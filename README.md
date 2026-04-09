# llvm15 overlay

Personal Gentoo overlay preserving LLVM 15 toolchain packages removed from the
official Gentoo tree, primarily to support the legacy Intel GPU OpenCL stack.

## Why this overlay exists

The Intel Graphics Compiler (IGC) versions that support Gen8/Gen9/Gen11 Intel
GPUs (Broadwell through Ice Lake) require LLVM 15. Upstream IGC dropped LLVM 15
support after v2.18.5 (September 2024), moving to LLVM 16+. Gentoo removed
LLVM 15 packages from the main tree in late 2024 as part of regular slot cleanup.

This overlay preserves the full LLVM 15 toolchain and the legacy Intel OpenCL
stack so that older Intel GPUs can continue to use OpenCL on Gentoo.

## Package groups

### LLVM 15 core toolchain (llvm-core/)

All at version 15.0.7, using Gentoo patchsets for GCC 15 / Python 3.14 compat:

- llvm-core/llvm (r7 patchset)
- llvm-core/clang (r3 patchset)
- llvm-core/clang-common, clang-runtime, clang-toolchain-symlinks
- llvm-core/lld, lld-toolchain-symlinks
- llvm-core/lldb
- llvm-core/libclc
- llvm-core/llvm-common, llvm-toolchain-symlinks, llvmgold

### LLVM 15 runtimes (llvm-runtimes/)

- compiler-rt, compiler-rt-sanitizers
- libcxx, libcxxabi, libunwind
- openmp (r6 patchset)

### Intel legacy GPU OpenCL stack

- **dev-util/intel-graphics-compiler** 1.0.17791.18 (SLOT=legacy)
  Requires LLVM 15. Three Gentoo patches: no -Werror, opencl-clang version
  detection workaround, git command removal.

- **dev-libs/intel-compute-runtime** 24.35.30872.{32,36,45} (SLOT=legacy)
  Legacy branch for Gen8/9/11 GPUs. Version .45 includes upstream
  GCC 15 fixes (no patch needed). Uses NEO_ALLOW_LEGACY_PLATFORMS_SUPPORT.

- **dev-util/spirv-llvm-translator** 15.0.{17,19,22} (SLOT=15)
  Bi-directional SPIR-V / LLVM IR translator. **Actively maintained upstream**
  by Khronos on the llvm_release_150 branch.

- **dev-libs/opencl-clang** 15.0.{5,8} (SLOT=15)
  Thin wrapper around clang for OpenCL. **Actively maintained upstream**
  by Intel on the ocl-open-150 branch.

### Python / OCaml bindings

- dev-python/lit, dev-python/clang
- dev-ml/llvm

## Dependency chain

```
intel-compute-runtime:legacy (24.35.x, Gen8/9/11 GPUs)
  +-- intel-graphics-compiler:legacy (1.0.17791.18)
  |     +-- opencl-clang:15 -> clang:15, llvm:15, spirv-llvm-translator:15
  |     +-- lld:15, llvm:15
  |     +-- spirv-llvm-translator:15 -> llvm:15
  +-- gmmlib, intel-metrics-discovery, level-zero, etc.
```

## Upstream status (as of April 2026)

| Component                | Status                                                    |
| ------------------------ | --------------------------------------------------------- |
| LLVM 15 core             | EOL since January 2023. Gentoo patchsets only.            |
| spirv-llvm-translator:15 | **Active** — Khronos releases regularly (latest v15.0.22) |
| opencl-clang:15          | **Active** — Intel releases regularly (latest v15.0.8)    |
| IGC (LLVM 15 line)       | EOL — v2.18.5 was the last LLVM 15 release                |
| compute-runtime (legacy) | Maintenance only on 24.35 branch                          |

## Potential future directions

1. **~~Bump IGC to v2.18.5~~** — REJECTED. v2.18.5 is in the IGCv2 product line,
   which is a separate package from the IGCv1 (1.0.x) line used by the legacy
   compute-runtime. Crossing product lines has unknown ABI compatibility risks
   and no community precedent. See `../research-tmp/igc-v2-bump-analysis.md`.
   Current IGC 1.0.17791.18 (IGCv1) is the correct version for this stack.
2. **Binary repackage ebuilds** — Intel provides pre-built Ubuntu .deb packages
   for the legacy stack (IGCv1 1.0.17537.24 + compute-runtime 24.35.x), which
   could bypass the LLVM 15 build dependency entirely. Arch Linux AUR already
   does this (`intel-graphics-compiler-legacy-bin`).
3. **Migrate to LLVM 16+ IGC** — requires Gen12+ hardware (not applicable for
   legacy GPU users)

## Related overlays

- **llvm14/** — sibling overlay preserving LLVM 14 packages
- **localrepo/** — main personal overlay

## References

- Gentoo bug #920541: IGC requires LLVM 15
  https://bugs.gentoo.org/920541
- Intel legacy platforms documentation:
  https://github.com/intel/compute-runtime/blob/master/LEGACY_PLATFORMS.md
- Arch Linux AUR legacy packages:
  https://aur.archlinux.org/packages/intel-graphics-compiler-legacy
- Research notes: ../research-tmp/
