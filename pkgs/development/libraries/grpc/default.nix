{ stdenv, fetchFromGitHub, fetchpatch, cmake, zlib, c-ares, pkgconfig, openssl, protobuf, gflags, abseil-cpp }:

stdenv.mkDerivation rec {
  version = "1.28.1"; # N.B: if you change this, change pythonPackages.grpcio and pythonPackages.grpcio-tools to a matching version too
  pname = "grpc";
  src = fetchFromGitHub {
    owner = "grpc";
    repo = "grpc";
    rev = "v${version}";
    sha256 = "17p3xwz5izlqg5ijnim4asl40pr8yhg9wrrmws4g0dk37nkn1x6p";
    fetchSubmodules = true;
  };
  patches = [
    # Fix build on armv6l (https://github.com/grpc/grpc/pull/21341)
    (fetchpatch {
      url = "https://github.com/grpc/grpc/commit/198d221e775cf73455eeb863672e7a6274d217f1.patch";
      sha256 = "11k35w6ffvl192rgzzj2hzyzjhizdgk7i56zdkx6v60zxnyfn7yq";
    })
  ];

  nativeBuildInputs = [ cmake pkgconfig ];
  buildInputs = [ zlib c-ares c-ares.cmake-config openssl protobuf gflags ];

  cmakeFlags =
    [ "-DgRPC_ZLIB_PROVIDER=package"
      "-DgRPC_CARES_PROVIDER=package"
      "-DgRPC_SSL_PROVIDER=package"
      "-DgRPC_PROTOBUF_PROVIDER=package"
      "-DgRPC_GFLAGS_PROVIDER=package"
      "-DBUILD_SHARED_LIBS=ON"
      "-DCMAKE_SKIP_BUILD_RPATH=OFF"
    ];

  # CMake creates a build directory by default, this conflicts with the
  # basel BUILD file on case-insensitive filesystems.
  preConfigure = ''
    rm -vf BUILD
  '';

  preBuild = ''
    export LD_LIBRARY_PATH=$(pwd)''${LD_LIBRARY_PATH:+:}$LD_LIBRARY_PATH
  '';

  NIX_CFLAGS_COMPILE = stdenv.lib.optionalString stdenv.cc.isClang "-Wno-error=unknown-warning-option";

  enableParallelBuilds = true;

  meta = with stdenv.lib; {
    description = "The C based gRPC (C++, Python, Ruby, Objective-C, PHP, C#)";
    license = licenses.asl20;
    maintainers = [ maintainers.lnl7 maintainers.marsam ];
    homepage = "https://grpc.io/";
    platforms = platforms.all;
    changelog = "https://github.com/grpc/grpc/releases/tag/v${version}";
  };
}
