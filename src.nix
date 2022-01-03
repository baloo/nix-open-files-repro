rec {
  pname = "jolokia";
  # If you bump this version, please remember you need to run the build-project-info.sh script
  # available in this repository.
  # It will rebuild the project-info.json that is required to build the local copy of a
  # maven repository.
  version = "1.7.1";
  src = builtins.fetchurl {
    url = "https://github.com/rhuss/${pname}/releases/download/v${version}/${pname}-${version}-source.tar.gz";
    sha256 = "18l1548z7kc5nlxjhwg9i64yr76wl991dz9bwwmnd2nd89cdyw2z";
  };
}
