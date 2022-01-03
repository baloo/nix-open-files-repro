# jolokia is a JMX proxy to expose JMX metrics via HTTP
# This is required for exporting metrics via telegraf

{ lib
, pkgs
, stdenv
, stdenvNoCC
, fetchurl
, maven
}:

let
  # Fork of <nixpkgs/pkgs/build-support/build-maven.nix> to make the repository build
  # multi-level.
  # Upstream build-maven.nix has a 512 dependency limit (open files (.jar + .pom) is
  # limited to 1024.
  # Sadly jolokia has 633 dependencies as of writing.
  buildMaven = pkgs.callPackage ./build-maven.nix { };

  inputs = import ./src.nix;
  inherit (inputs) pname version src;

  # Only FOD (Fixed Output Derivation) have access to internet, we'll build a dependencies repository first
  # which is expected to get a fixed hash output.
  # We'll then feed that repository to out software build once done, so it can build without internet access.
  repository = (buildMaven ./project-info.json).repo;
in stdenv.mkDerivation {
  inherit src pname version;

  buildInputs = [ maven ];
  # Skip tests because the tests try to reach out to ftp.redhat.com and fails because it's running inside a sandbox.
  buildPhase = ''
    echo "Using repository ${repository}"
    mvn \
      --offline -Dmaven.repo.local=${repository} \
      -DskipTests \
      package
  '';
  installPhase = ''
    echo $(find . -name target)/*.jar
    install -Dm644 ./client/jmx-adapter/target/jolokia-jmx-adapter-${version}-standalone.jar $out/share/java
  '';
}
