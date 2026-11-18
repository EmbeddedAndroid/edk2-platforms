# NordOpenBoardPkg

Firmware for Nord (SA8797P) boards booted through the open boot stack, built
as a thin board layer on top of [NordMinPlatformPkg](../NordMinPlatformPkg).

## Boot flow

XBL loads the TF-A BL2. BL2 loads a FIP holding BL31, OP-TEE (BL32) and this
firmware (BL33), placing it at the TF-A BL33 load address (`NORD_FD_BASE`,
0xA0200000). BL31 launches BL33 at offset 0, in EL2.

There is no XBL boot device tree on this path, so `ArmPlatformLib` takes the
static memory map: the region holding the FD from the PCDs, and every SDRAM
partition above it from the SMEM RAM partition table.

## Capabilities

- UEFI Shell and UiApp
- UFS boot: BDS enumerates the ESP on UFS and boots `\EFI\BOOT\BOOTAA64.EFI`
- The device tree is supplied by the OS loader (for example a UKI with a
  `.dtb` section); the firmware does not publish one

## How to build

`edk2` and `edk2-platforms` are checked out side by side in `$WORKSPACE`.
The host needs `gcc`, `make`, `python3` and the libuuid headers (for
BaseTools).
On an AARCH64 host the system `gcc` is used; on any other host set
`GCC_AARCH64_PREFIX` to a cross compiler, for example `aarch64-linux-gnu-`.

```bash
export WORKSPACE=$PWD
export PACKAGES_PATH=$WORKSPACE/edk2:$WORKSPACE/edk2-platforms:\
$WORKSPACE/edk2-platforms/Platform:$WORKSPACE/edk2/ArmPlatformPkg:\
$WORKSPACE/edk2-platforms/Platform/Qualcomm:\
$WORKSPACE/edk2-platforms/Platform/Qualcomm/NordFamily:\
$WORKSPACE/edk2-platforms/Platform/Qualcomm/Common:\
$WORKSPACE/edk2-platforms/Silicon/Qualcomm:\
$WORKSPACE/edk2-platforms/Silicon/Qualcomm/Common
. edk2/edksetup.sh
make -C edk2/BaseTools
build -a AARCH64 -t GCC -b DEBUG \
  -p Platform/Qualcomm/NordFamily/NordOpenBoardPkg/NordOpenBoardPkg.dsc
```

`-b RELEASE` and `-b NOOPT` build the same way.

The firmware device is
`Build/NordOpenBoardPkg/DEBUG_GCC/FV/NORDMINPLATFORMPKG.fd`. Pass it to the
TF-A build as the BL33 image, for example:

```bash
fiptool create --soc-fw bl31.bin --tos-fw tee-raw.bin \
  --nt-fw NORDMINPLATFORMPKG.fd fip.bin
```

## How to flash and boot

The FIP needs a TF-A with the Nord platform (`PLAT=nord`, not upstream yet)
and OP-TEE built for `PLATFORM=qcom-nord`, both from their own trees.

- Sign BL2 for the secure boot configuration of the part, and write it to
  the `tz_a` and `tz_b` partitions.
- Wrap the FIP in an ELF image, sign it like the XBL-loaded image it replaces,
  and write it to `uefi_a` and `uefi_b`.
- Both are on UFS (LUN 4 and LUN 5) and can be written in EDL mode, for
  example with `qdl`.

At boot BDS enumerates the UFS LUNs and starts `\EFI\BOOT\BOOTAA64.EFI` from
the ESP, for example a UKI carrying the Linux kernel, initrd and the board
device tree. The firmware logs to the debug UART, which XBL sets up.

## Important notes

- UEFI variables are emulated in memory and do not persist across boots.
- Secure boot is not available.

## Glossary

- BDS: Boot Device Selection, the boot phase that picks the boot option
- BL2, BL31, BL32, BL33: TF-A boot loader stages; BL31 is the EL3 runtime,
  BL32 the secure OS (OP-TEE), BL33 the non-secure firmware (this one)
- EDL: Emergency Download, the Qualcomm boot ROM USB flashing mode
- ESP: EFI System Partition
- FIP: TF-A Firmware Image Package
- LUN: UFS Logical Unit
- SMEM: Qualcomm shared memory, which carries the RAM partition table
- UKI: Unified Kernel Image (kernel, initrd and DT in one EFI binary)
- XBL: Qualcomm eXtensible Boot Loader, the stage before TF-A BL2
