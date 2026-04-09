# Contributing to the llvm15 overlay

## Development workflow

1. Install required tools:

   ```bash
   emerge --ask dev-util/pkgcheck dev-util/pkgdev dev-vcs/pre-commit
   ```

2. Clone the repository and install pre-commit hooks:

   ```bash
   git clone <repo-url>
   cd llvm15
   pre-commit install
   ```

3. Make your changes. When adding or updating packages:

   ```bash
   # After editing an ebuild, regenerate the Manifest
   pkgdev manifest

   # Or regenerate all manifests in the overlay
   pkgdev manifest -r .
   ```

4. Check for QA issues:

   ```bash
   pkgcheck scan
   ```

5. Commit with `pkgdev commit` (runs checks and regenerates manifests):

   ```bash
   pkgdev commit
   ```

## Scope guidelines

This overlay has a **narrow scope**: preserve LLVM 15 and the legacy Intel
GPU OpenCL stack. Do NOT add:

- LLVM versions other than 15 (use llvm14 overlay for 14, main tree for 16+)
- Non-legacy Intel GPU packages (use main tree)
- Unrelated packages (use localrepo or create a new overlay)

## Ebuild guidelines

- Use `llvm-core/`, `llvm-runtimes/` categories (not legacy `sys-devel/`,
  `sys-libs/`)
- LLVM core packages use Gentoo patchsets via `LLVM_PATCHSET=...`
- Intel legacy packages stay in the IGCv1 product line (1.0.x), NOT IGCv2 (2.x)
- Keep `PYTHON_COMPAT=( python3_{10..14} )` consistent across all ebuilds
- SLOT conventions:
  - LLVM core: `SLOT="${LLVM_MAJOR}/${LLVM_SOABI}"` (e.g., `15/15`)
  - Intel stack: `SLOT="legacy/..."` (e.g., `legacy/1.0.1`)

## LLVM patchset tracking

Periodically check if Gentoo has bumped the `LLVM_PATCHSET` values in the
main tree for 15.0.7 ebuilds. The Gentoo LLVM team sometimes backports
GCC/Python compatibility fixes to the archived patchsets.

```bash
# From a Gentoo tree checkout
cd /var/db/repos/gentoo
git log --oneline -- 'llvm-runtimes/compiler-rt/*15.0.7*' 'llvm-core/llvm/*15.0.7*'
```

## Version bump checklist

When bumping a package:

1. Check upstream CHANGELOG for breaking changes
2. Verify the new version still supports LLVM 15 (if applicable)
3. Check if any patches can be dropped (upstreamed fixes)
4. Check if new patches are needed
5. Update `CHANGELOG.md`
6. Add a news item if user-visible
7. Run `pkgcheck scan`
8. Run `pkgdev manifest`

## CI checks

Every PR runs:

- **pkgcheck**: Gentoo QA checks
- **manifest**: Verifies Manifest files
- **pre-commit**: Text hygiene, shellcheck, Gentoo-specific hooks

Fix any issues before merging.
