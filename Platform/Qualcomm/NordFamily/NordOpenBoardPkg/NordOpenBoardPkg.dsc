## @file
#  The main build description file for the NordOpenBoardPkg
#
#  Board package for Nord boards booted through the open boot stack: TF-A
#  loads this firmware as the BL33 payload, with OP-TEE as the BL32.
#
#  Copyright (c) Qualcomm Technologies, Inc. and/or its subsidiaries.<BR>
#  SPDX-License-Identifier: BSD-2-Clause-Patent
##

[Defines]
  DSC_SPECIFICATION           = 1.30
  PLATFORM_GUID               = 28376B3F-94BA-436E-A1F6-008A229C6A62
  PLATFORM_NAME               = NordOpenBoardPkg
  PLATFORM_VERSION            = 1.0
  SUPPORTED_ARCHITECTURES     = AARCH64
  FLASH_DEFINITION            = $(PLATFORM_NAME)/$(PLATFORM_NAME).fdf
  OUTPUT_DIRECTORY            = Build/$(PLATFORM_NAME)
  BUILD_TARGETS               = DEBUG | RELEASE | NOOPT
  SKUID_IDENTIFIER            = ALL
  SMM_REQUIRED                = FALSE

  #
  # TF-A BL33 load address on Nord.
  #
  DEFINE NORD_FD_BASE         = 0xA0200000

!include NordMinPlatformPkg/NordMinPlatformPkg.dsc.inc

[LibraryClasses.AARCH64]
  ArmGenericTimerCounterLib|ArmPkg/Library/ArmGenericTimerVirtCounterLib/ArmGenericTimerVirtCounterLib.inf

[PcdsFixedAtBuild]
  gQualcommMinPlatformPkgTokenSpaceGuid.PcdBootDtBase                     | 0x0
  gQualcommMinPlatformPkgTokenSpaceGuid.PcdBootDtSize                     | 0x0

  gMinPlatformPkgTokenSpaceGuid.PcdBootStage                              | 4
  gArmTokenSpaceGuid.PcdUefiShellDefaultBootEnable                        | FALSE
