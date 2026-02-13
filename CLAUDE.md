# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Purpose

Zigman renders the [Zig language reference](https://ziglang.org/documentation/master/) as a beautifully typeset PDF suitable for e-book readers (e.g. Kindle, Kobo, reMarkable). It uses **Pandoc** to convert HTML to Typst markup, **Typst** for document layout, and **Nix** for reproducible builds.

## Build Commands

```bash
# Build the PDF via Nix (reproducible, preferred)
nix build

# Build the PDF directly with Typst during development
typst compile main.typ zigman.pdf

# Watch for changes and recompile automatically
typst watch main.typ zigman.pdf
```

## Architecture

The pipeline has three stages:

1. **Fetch**: Obtain the Zig language reference HTML from ziglang.org.
2. **Convert**: Use Pandoc (`html → typst`) to produce Typst-compatible markup. A Lua filter or preprocessing step handles Zig-specific HTML quirks.
3. **Typeset**: Typst compiles the markup into a PDF optimized for e-reader page dimensions and readability.

Nix ties all stages together into a single reproducible build via `flake.nix`.

## CI

PDF builds run on **GitHub Actions** using the Nix flake. The CI workflow installs Nix with flakes enabled and runs `nix build`. No other build tooling should be required in CI — everything is declared in the flake.

## Key Technologies

- **Pandoc** — converts the Zig reference HTML to Typst markup. Supports custom templates (`--template`) and Lua filters for fine-tuning output.
- **Typst** — modern typesetting system (alternative to LaTeX). Files use `.typ` extension. Docs: https://typst.app/docs
- **Nix flakes** — reproducible builds and dependency management. Entry point: `flake.nix`
- **GitHub Actions** — CI runs `nix build` to produce the PDF. Workflow lives in `.github/workflows/`.
