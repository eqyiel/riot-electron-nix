{ stdenv, fetchurl, runCommand, writeScriptBin, electron, bash, gnutar, pkgs, system, nodejs }:
let
nodePackages = import ./node { inherit pkgs system nodejs; };
riot = stdenv.mkDerivation rec {
  name = "riot-desktop-${version}";
  version = "0.11.3";

  src = fetchurl {
    url = "https://github.com/vector-im/riot-web/releases/download/v${version}/riot-v${version}.tar.gz";
    sha256 = "0znh3armdxpa9kir9pqxx7zb6an8bydya96713zpjwfsf6fja84b";
  };

  nativeBuildInputs = [ gnutar ];

  buildCommand = ''
    mkdir -p "$out/webapp"
    tar xf '${src}' --strip-components=1 -C "$out/webapp"
    cp -r '${nodePackages."riot-web-file:../riot-web/electron_app"}/lib/node_modules/riot-web/' "$out/electron"
  '';
};
in writeScriptBin "riot" ''
  #!${bash}/bin/sh
  ${electron}/bin/electron "${riot}/electron" "$@"
''
