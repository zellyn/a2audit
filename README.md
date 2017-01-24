# Apple II Audit

This repository contains routines to audit Apple II computers (II,
II+, IIe, IIc), providing information about hardware, ROM versions,
RAM configuration, and behavior.

Eventually, it should comprise a complete emulator test suite,
enabling emulator writers to systematically identify and eliminate
software-testable differences from real hardware. If a difference
visible to code can be found, a test should be added to this suite.

# Error messages

Error messages can be viewed at
[zellyn.com/a2audit/a2audit/v0](http://zellyn.com/a2audit/v0/) or
[on github](https://github.com/zellyn/a2audit/blob/master/v0/index.md).

## Status

### Done

- [x] toolchain for automation ([diskii](github.com/zellyn/diskii))
- [x] sha1sum assembly code (currently not used yet because it's slow)
- [x] language card tests
- [x] main/auxiliary memory softswitch behavior tests

### TODO

- [ ] floating-bus tests

## Raison d'être

This test suite is a step on the way to implementing Apple IIe
(enhanced) support in
[OpenEmulator](http://openemulatorproject.github.io/): I may alternate
adding tests here and features there.

