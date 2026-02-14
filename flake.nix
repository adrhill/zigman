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

      perSystem = system:
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
              ${langref-html} \
              -o content-raw.typ

            # Strip #link(<toc-...>)[text] → text in headings
            # Pandoc's typst writer generates these for TOC linking but we
            # handle the TOC in main.typ via Typst's outline()
            sed -E 's/#link\(<toc-[^>]+>\)\[([^]]*)\]/\1/g' content-raw.typ > $out
          '';
        in
        {
          package = pkgs.runCommand "zigman-pdf" {
            nativeBuildInputs = [ pkgs.typst pkgs.literata pkgs.source-code-pro ];
            TYPST_FONT_PATHS = "${pkgs.literata}/share/fonts:${pkgs.source-code-pro}/share/fonts";
          } ''
            mkdir -p $out
            cp ${./main.typ} main.typ
            cp ${content-typ} content.typ
            # Page dimensions default to 6in×9in via sys.inputs in main.typ.
            # For custom sizes, use the dev shell:
            #   typst compile --input page-width=5in --input page-height=7in main.typ zigman.pdf
            ${pkgs.typst}/bin/typst compile main.typ $out/zigman.pdf
          '';

          devShell = pkgs.mkShell {
            packages = [
              pkgs.pandoc
              pkgs.typst
              pkgs.curl
              pkgs.literata
              pkgs.source-code-pro
            ];
            shellHook = ''
              export TYPST_FONT_PATHS="${pkgs.literata}/share/fonts:${pkgs.source-code-pro}/share/fonts"

              if [ ! -f content.typ ]; then
                echo "Copying content.typ from Nix build..."
                cp ${content-typ} content.typ
                echo "content.typ ready."
              fi
            '';
          };
        };
    in
    {
      packages = forAllSystems (system: {
        default = (perSystem system).package;
      });

      devShells = forAllSystems (system: {
        default = (perSystem system).devShell;
      });
    };
}
