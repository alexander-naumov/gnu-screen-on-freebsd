# CI/CD GNU Screen on FreeBSD

<img align="right" src="freebsd-daemon.jpg" height="200">

This project builds the FreeBSD VM image for the
[cross-platform-actions/action](https://github.com/cross-platform-actions/action)
GitHub action. The image contains a standard FreeBSD installation without any
expectations of running X.

In addition to standard installation, the following packages are installed as
well:

* sudo
* bash
* curl
* gcc
* gmake
* git
* print/texinfo
* autoconf
* indexinfo
* automake

Except for the root user, there's one additional user, `runner`, which is the
user that will be running the commands in the GitHub action. This user is
allowed use `sudo` without a password.

## Architectures and Versions

The following architectures and versions are supported:

| Version | x86-64 | ARM64 |
|---------|--------|-------|
| 14.0    | ✓      | ✓     |
| 13.3    | ✓      | ✓     |
| 13.2    | ✓      | ✓     |
| 13.1    | ✓      | ✓     |
| 13.0    | ✓      | ✓     |

## Building Locally

### Prerequisite

* [Packer](https://www.packer.io) 1.9.1 or later
* [QEMU](https://qemu.org)

### Building

1. Clone the repository:
    ```
    % git clone https://github.com/cross-platform-actions/freebsd-builder
    % cd freebsd-builder
    ```

2. Run `build.sh` to build the image:
    ```
    % ./build.sh <version> <architecture>
    ```
    Where `<version>` and `<architecture>` are the any of the versions or
    architectures available in the above table.

3. Get the GNU Screen source code from the devel repository and build it:
    ```
    % uname -a
    % cc -v
    % git -c http.sslVerify=false clone https://github.com/alexander-naumov/gnu-screen.git
    % cd gnu-screen/src
    % ./autogen.sh

    % cc=gcc ./configure CFLAGS="-Wall"
    % gmake
    % ./screen -v
    % ./screen -ls || echo $?
    % gmake clean

    % cc=clang ./configure CFLAGS="-Wall -DDEBUG"
    % grep @CFLAGS@ Makefile.in
    % gmake
    % ./screen -v
    % ./screen -ls || echo $?
    % ./screen --help
    ```

The above command will build the VM image and the resulting disk image will be
at the path: `output/freebsd-<version>-<architecture>.qcow2`.

## Additional Information

At startup, the image will look for a second hard drive. If present and it
contains a file named `keys` at the root, it will install this file as the
`authorized_keys` file for the `runner` user. The disk is expected to be
formatted as FAT32. This is used as an alternative to a shared folder between
the host and the guest, since this is not supported by the xhyve hypervisor.
FAT32 is chosen because it's the only filesystem that is supported by both the
host (macOS) and the guest (FreeBSD) out of the box.

The disk needs to be configured with the GPT partitioning scheme. The VM needs
to be configured to use UEFI. This is required for the VM image to be able to
run using the xhyve hypervisor.

The qcow2 format is chosen because unused space doesn't take up any space on
disk, it's compressible and easily converts the raw format, used by xhyve.
