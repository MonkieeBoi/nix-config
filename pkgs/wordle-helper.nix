{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule {
  pname = "wordle-helper";
  version = "0-unstable-2025-09-05";

  src = fetchFromGitHub {
    owner = "MonkieeBoi";
    repo = "wordle-helper";
    rev = "93f321f50126c76d6b3263855d1faa52c698aba9";
    hash = "sha256-0uIFs3lE645PvXcWs/J7tk10QKQvmHMpRKsu71tENP8=";
  };

  vendorHash = "sha256-Rk3kYOL9mmgNFC1Op/zwDw4cc672aOkvwF8Wa+iEAD4=";

  meta = {
    description = "Simple TUI to cheat on wordle made with BubbleTea";
    homepage = "https://github.com/MonkieeBoi/gdn";
    license = lib.licenses.gpl3Only;
    mainProgram = "wordle-helper";
    maintainers = [ lib.maintainers.monkieeboi ];
  };
}
