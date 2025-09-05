{ pkgs ? import <nixpkgs> { } }:

let
  buildDerivation = name: version: sha256: lib:
    pkgs.stdenv.mkDerivation {
      name = "${name}-${version}";
      src = pkgs.fetchurl {
        url = "http://ftp.debian.org/debian/pool/main/${builtins.substring 0 1 name}/${name}/${name}_${version}_amd64.deb";
        sha256 = sha256;
      };

      buildInputs = [ pkgs.binutils pkgs.gnutar pkgs.pkg-config lib ];
      dontStrip = true; # in order to prevent `set` calls tampering with generated strip script

      unpackPhase = ''
        #!/bin/bash
        set -euo pipefail

        mkdir -p tmp/
        ar x $src
        mv data.tar.xz tmp/
      '';

      installPhase = ''
        #!/bin/bash
        set -euo pipefail

        mkdir -p $out/bin $out/lib
        tar -xf ./tmp/data.tar.xz -C $out
        mv $out/usr/bin/${name} $out/bin/
        cp $(pkg-config --variable=libdir ${lib.pname})/* $out/lib/
        rm -rf $out/usr tmp/
      '';
    };

  fromGithubRelease = { name, exeName, version, sha256, url ? null, artifactName ? null }:
    pkgs.stdenv.mkDerivation {
      name = "${exeName}-${version}";
      src =
        if url != null then
          pkgs.fetchzip
            {
              url = url;
              sha256 = sha256;
            }
        else if artifactName != null then
          pkgs.fetchzip
            {
              url = "https://github.com/${name}/releases/download/${version}/${artifactName}";
              sha256 = sha256;
            }
        else
          throw "Either artifactName or url must be supplied";

      installPhase = ''
        ls -lah
        mkdir -p $out/bin
        mv ${exeName} $out/bin/
      '';
    };

  getVersion = { exeName, name, pesdePackage ? null }:
    (
      let package = if pesdePackage == null then "pesde/${exeName}" else pesdePackage; in pkgs.stdenv.mkDerivation {
        name = "get-version";
        src = ./pesde.lock;
        buildInputs = [ pkgs.jq pkgs.toml2json ];
        phases = [ "buildPhase" ];
        buildPhase = ''
          #!/bin/bash
          set -euo pipefail

          version=$(toml2json $src | jq -r '.graph | with_entries(select(.key | test("^${package}"))) | to_entries[0].key | capture("(@(?<version>[^ ]+))") | .version')
          if [[ "${exeName}" = "stylua" ]]; then
            # Special case for stylua which has versions that start with `v`
            version="v$version"
          fi

          echo -n "$version" > $out
        '';
      }
    );

  fromPesdeManifest = { name, exeName, artifactName, pesdePackage ? null, sha256 }:
    let
      version = builtins.readFile (getVersion { exeName = exeName; name = name; pesdePackage = pesdePackage; });
    in
    fromGithubRelease {
      name = name;
      exeName = exeName;
      version = version;
      sha256 = sha256;
      artifactName = artifactName;
    };

in
pkgs.mkShell {
  buildInputs = [
    # General devtools and test requirements
    pkgs.curl
    pkgs.git
    (buildDerivation "unzip" "6.0-29" "YY30d9W3BOQ3z45mBtA68pGtCzPc+5ZNQI940weTOpU=" pkgs.bzip2)
    (buildDerivation "zip" "3.0-15" "e/y9Af0ZyPdFMzVh/AbEra2fS0FtRfhoXNgfsYf1Wcs=" pkgs.zlib)

    # Luau tooling
    pkgs.lune
    (fromGithubRelease {
      name = "pesde-pkg/pesde";
      exeName = "pesde";
      version = "v0.7.1+registry.0.2.3";
      artifactName = "pesde-0.7.1-linux-x86_64.zip";
      sha256 = "Df1tyq0cDt6dvU7usPdOVwcaY6yNF7ths/TGhhq2X24=";
    })
    (fromGithubRelease {
      name = "evaera/moonwave";
      exeName = "moonwave-extractor";
      version = "v1.3.0";
      artifactName = "moonwave-extractor-v1.3.0-linux.zip";
      sha256 = "RMFdmEat+F/4WdLtcl/d8r1D6eRp8xsk05zEmMiYi2M=";
    })
    (fromPesdeManifest {
      name = "JohnnyMorganz/luau-lsp";
      exeName = "luau-lsp";
      pesdePackage = "pesde/luau_lsp";
      artifactName = "luau-lsp-linux-x86_64.zip";
      sha256 = "vyQUyJnBSRJl/18Y7sbk2f2BW5pzXz+YUcJ9Cv2zngo=";
    })
    (fromPesdeManifest {
      name = "JohnnyMorganz/StyLua";
      exeName = "stylua";
	  pesdePackage = "pesde/stylua";
      artifactName = "stylua-linux-x86_64.zip";
      sha256 = "24VY/zesW5+t7dP0jMD4jHR/xYUHqKVG3utkmTetjHY=";
    })
  ];

  shellHook = ''
    # Add pesde bins dir to path
    export PATH="$PATH:$HOME/.pesde/bin"
  '';
}

