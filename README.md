![Docker Image CI](https://github.com/malikkirchner/cpp-builder/workflows/Docker%20Image%20CI/badge.svg?branch=master)

# C++ builder image

A C++ build and test image, that contains Clang, GCC and CMake. This images is
based on Arch Linux, hence it follows a rolling release strategy. To enable
easy C++ builds and tests following software is installed
* Git for versioning and checkout
* GCC and Clang as compilers
* Make and Ninja as build tools
* CMake and Autotools as build system generators
* Boost, OpenSSL, Protobuf and GTest
* Flex and Bison as parser generator
* CCache as build cache
* GDB as default debugger
* CTest and PyTest for complex test scenarios
* Doxygen and GraphViz to generate documentation
* SLOCCount to count lines of code
* rsync, ssh, pixz, unzip, ...

Those packages are meant to be used as build time dependencies. If you require pre-compiled
runtime dependencies, please consider to use a C++ packet manager like Conan.

You can use a volume mount at `/home/builder/ccache` to make the build cache persistent.
The source code should be mounted at `/workspace` and all builds should run as user `builder`
with UID and GID 1000.
