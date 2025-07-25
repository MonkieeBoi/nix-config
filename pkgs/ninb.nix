# THIS ENTIRE THING IS SUPA DODGY DON'T COPY/USE LOL
{
  lib,
  stdenv,
  fetchurl,
  makeWrapper,
  jre,
  libxkbcommon,
  xorg,
}:
stdenv.mkDerivation rec {
  name = "ninb";
  version = "1.5.1";

  src = fetchurl {
    url = "https://github.com/Ninjabrain1/Ninjabrain-Bot/releases/download/${version}/Ninjabrain-Bot-${version}.jar";
    hash = "sha256-Rxu9A2EiTr69fLBUImRv+RLC2LmosawIDyDPIaRcrdw=";
  };

  dontUnpack = true;

  nativeBuildInputs = [
    makeWrapper
  ];

  installPhase = ''
    runHook preInstall

    install -Dm644 ${src} $out/share/java/${name}-${version}.jar 

    makeWrapper ${jre}/bin/java $out/bin/ninb \
      --add-flags "-Dswing.defaultlaf=javax.swing.plaf.metal.MetalLookAndFeel -jar $out/share/java/${name}-${version}.jar" \
      --prefix LD_LIBRARY_PATH : ${
        lib.makeLibraryPath [
          libxkbcommon
          xorg.libX11
          xorg.libXt
          xorg.libXtst
          xorg.libXinerama
          xorg.libxcb
        ]
      }

    runHook postInstall
  '';

  meta = {
    homepage = "https://github.com/Ninjabrain1/Ninjabrain-Bot";
    description = "Accurate stronghold calculator for Minecraft speedrunning.";
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [
      monkieeboi
    ];
  };
}
