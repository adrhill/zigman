# Zigman

The [Zig Language Reference](https://ziglang.org/documentation/master/) as a typeset PDF for e-readers.

**Download the latest PDF:** [zigman.pdf](https://adrianhill.de/zigman/zigman.pdf)

## Build

Build script uses Nix:

```bash
nix build
```

The PDF will be at `./result/zigman.pdf` (default 4.2"×5.6", sized for Boox Go Color 7).

### Custom page sizes

In the dev shell, page dimensions can be customized via Typst's `--input` flag:

```bash
nix develop
typst compile --input page-width=5in --input page-height=7in main.typ zigman.pdf
```

## How it works

Zigman fetches the Zig Language Reference HTML from ziglang.org, converts it to Typst markup using Pandoc (with a Lua filter to clean up Zig-specific HTML quirks), and typesets it into a PDF with Typst.
