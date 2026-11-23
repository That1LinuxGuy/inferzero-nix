{
  lib,
  stdenv,
  fetchFromGitHub,
  makeWrapper,
  bash,
  ocl-icd,
  level-zero,
  intel-compute-runtime,
  curl,
  libidn2,
  source ? null,
}:

stdenv.mkDerivation {
  pname = "inferzero";
  version = "latest";

  # Pinned upstream name irrelevant to build output 
  # Flake will provide the latest package
  src =
    if source != null then
      source
    else
      fetchFromGitHub {
        owner = "rizagp";
        repo = "inferzero";
        rev = "2026.11.23.09";
        hash = "sha256-tMeJlyFJz/vVvkGF6E2VT5RjxtVj94FJsTJ5qK1i8o4=";
      };

  nativeBuildInputs = [ bash makeWrapper ];

  buildPhase = ''
    runHook preBuild
    bash ./build.sh runz serverz
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    install -Dm755 bin/runz "$out/libexec/inferzero/runz"
    install -Dm755 bin/serverz "$out/libexec/inferzero/serverz"

    mkdir -p "$out/bin" "$out/share/inferzero/zero"
    cp -r zero/kernels "$out/share/inferzero/zero/kernels"
    cp -r webui "$out/share/inferzero/webui"
    # The server reads options.tsv; draft-vocab/ is used by opt-in MTP drafting.
    cp -r scripts "$out/share/inferzero/scripts"

    # Both programs read kernel files relative to the working directory.
    # Use absolute model paths when invoking these wrappers.
    for program in runz serverz; do
      makeWrapper "$out/libexec/inferzero/$program" "$out/bin/$program" \
        --chdir "$out/share/inferzero" \
        --prefix LD_LIBRARY_PATH : \
          "${lib.makeLibraryPath [ ocl-icd level-zero intel-compute-runtime curl libidn2 ]}"
    done

    runHook postInstall
  '';

  meta = {
    description = "Local LLM inference engine for Intel Arc GPUs";
    homepage = "https://github.com/rizagp/inferzero";
    license = lib.licenses.asl20;
    platforms = [ "x86_64-linux" ];
    mainProgram = "serverz";
  };
}
