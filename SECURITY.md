# Security Policy

## Scope

This is a **personal Gentoo overlay** preserving the LLVM 15 toolchain and the
legacy Intel Graphics Compiler stack that were removed from the official Gentoo
tree. It exists to support legacy Intel GPUs (Gen8/Gen9/Gen11) that require
IGCv1 + LLVM 15 for OpenCL support.

## Supported Versions

Only the **latest version of each package** in this overlay receives updates.
Older versions are kept for rollback but not patched.

**LLVM 15 is end-of-life upstream** (final release: 15.0.7, January 2023). No
new security fixes are available from the LLVM project. Gentoo patchsets
(`LLVM_PATCHSET=15.0.7-rN`) continue to provide GCC/Python compatibility fixes.

For security issues in:

- **LLVM itself**: No upstream support. Consider upgrading hardware and
  migrating to a newer LLVM version.
- **Intel Graphics Compiler**: https://github.com/intel/intel-graphics-compiler/security
- **Intel Compute Runtime**: https://github.com/intel/compute-runtime/security
- **SPIRV-LLVM-Translator**: https://github.com/KhronosGroup/SPIRV-LLVM-Translator/security
- **opencl-clang**: https://github.com/intel/opencl-clang

## Reporting Issues With the Overlay

For issues specific to the **ebuilds in this overlay** (build failures,
incorrect dependencies, QA issues, wrong patchset versions, etc.):

- Open a GitHub issue on this repository
- For sensitive issues, use GitHub's private vulnerability reporting feature

## Integrity Guarantees

- All distfiles are verified via BLAKE2B and SHA512 hashes in Manifest files
- LLVM patchsets are fetched from `dev.gentoo.org` with SHA512 verification
  via the `llvm.org` eclass
- Intel and Khronos projects do NOT provide GPG signatures for their
  release tarballs
- CI runs `pkgdev manifest` verification on every PR

## Threat Model

This overlay is intended for **personal use on trusted systems**. LLVM is a
compiler toolchain, not a network-facing service. Security vulnerabilities
in LLVM typically require processing malicious input (bitcode, IR, debug
info), which is not an attack vector in normal compilation workflows.

If you are compiling untrusted code, the EOL status of LLVM 15 is a
concern and you should migrate away from this overlay.
