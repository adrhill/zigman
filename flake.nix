{
  description = "Zigman — Zig Language Reference typeset for e-readers";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      forAllSystems = nixpkgs.lib.genAttrs [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
    in
    {
      packages = forAllSystems (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};

          langref-html = pkgs.fetchurl {
            url = "https://ziglang.org/documentation/master/index.html";
            hash = "sha256-Kj7MrOwrGclQ35A9xkU0sXLpGki0yaO61P/72KqgZVM=";
          };

          content-typ = pkgs.runCommand "zigman-content" {
            nativeBuildInputs = [ pkgs.pandoc pkgs.gnused ];
          } ''
            ${pkgs.pandoc}/bin/pandoc \
              -f html \
              -t typst \
              --lua-filter=${./filter.lua} \
              --template=${./template.typ} \
              ${langref-html} \
              -o content-raw.typ

            # Strip #link(<toc-...>)[text] → text in headings
            # Pandoc's typst writer generates these for TOC linking but we
            # handle the TOC in main.typ via Typst's outline()
            sed -E 's/#link\(<toc-[^>]+>\)\[([^]]*)\]/\1/g' content-raw.typ > $out
          '';
        in
        {
          default = pkgs.runCommand "zigman-pdf" {
            nativeBuildInputs = [ pkgs.typst ];
          } ''
            mkdir -p $out
            cp ${./main.typ} main.typ
            cp ${content-typ} content.typ
            # Page dimensions default to 6in×9in via sys.inputs in main.typ.
            # For custom sizes, use the dev shell:
            #   typst compile --input page-width=5in --input page-height=7in main.typ zigman.pdf
            ${pkgs.typst}/bin/typst compile main.typ $out/zigman.pdf
          '';
        }
      );

      devShells = forAllSystems (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          default = pkgs.mkShell {
            packages = [
              pkgs.pandoc
              pkgs.typst
              pkgs.curl
            ];
          };
        }
      );
    };
}
