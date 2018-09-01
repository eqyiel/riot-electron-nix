{ stdenv
, electron
, fetchurl
, makeDesktopItem
, nodejs
, pkgs
, riot-web
, system
}:

let
  desktopItem = makeDesktopItem {
    name = "riot";
    desktopName = "Riot";
    genericName = "Matrix Client";
    exec = "riot";
    comment = "A feature-rich client for Matrix.org";
    icon = "riot";
    categories = "Network;InstantMessaging;Chat;";
    extraEntries = ''
      StartupWMClass="Riot"
    '';
  };

  webApp = riot-web.overrideAttrs (attrs: rec {
    name= "riot-web-${version}";
    version = "0.16.2";

    src = fetchurl {
      url = "https://github.com/vector-im/riot-web/releases/download/v${version}/riot-v${version}.tar.gz";
      sha256 = "14k8hsz2i1nd126jprvi45spdxawk4c8nb3flkrg7rmjdp5sski2";
    };
  });

  electronApp = (import ./node { inherit pkgs system nodejs; })."riot-web-file:../riot-web/electron_app";

in stdenv.mkDerivation {
  name = "riot-desktop-${webApp.version}";
  inherit (webApp) version;

  buildCommand = ''
    mkdir -p "$out/share/riot"
    ln -s '${webApp}' "$out/share/riot/webapp"
    cp -r '${electronApp}/lib/node_modules/riot-web/' "$out/share/riot/electron"

    for i in 16 24 48 64 96 128 256 512; do
      mkdir -p "$out/share/icons/hicolor/''${i}x''${i}/apps"
      ln -s "$out/share/riot/electron/build/icons/''${i}x''${i}.png" \
        "$out/share/icons/hicolor/''${i}x''${i}/apps/riot.png"
    done

    cp -r '${desktopItem}/.' "$out"
    mkdir -p "$out/bin"
    cat > "$out/bin/riot" <<EOF
    #!${stdenv.shell}
    '${electron}/bin/electron' "$out/share/riot/electron" "$@"
    EOF
    chmod +x "$out/bin/riot"
  '';
}
