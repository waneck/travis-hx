# hx-travis
Helpers (and wikis) to easily test haxe code on travis

### Environment variables
The following environment variables are sensitive by the script runtime:

#### TARGET
Defines the setup to be configured. This has exactly a 1:1 correspondence with the haxe target defined by the command-line

#### TARGET_DIR
The target file as specified by the haxe build.

#### HXFLAGS
If you decide to build using hx-travis' build scripts, use this flag to configure the flags used to call the haxe compiler

#### OS and ARCH
Defines the OS and architecture to be used as test. The following combinations may be used:

| ARCH    |    OS    | Description      |  Implemented targets                                  |
| ------  | -------- | ---------------- | ----------------------------------------------------- |
| x86_64* | Linux    | 64-bit           | all; flash is always 32-bit
| x86_64* | Mac      | 64-bit           | all; flash is always 32-bit
| i686    | Linux    | 32-bit           | haxe, neko, js (node and phantomjs), php
| i686    | Mac      | 32-bit           | none

#### TOOLCHAIN
If applicable, specifies a custom toolchain to be used for building / running. Default is always `default`

|   OS    |    ARCH    |    TARGET    |  TOOLCHAIN  | Remarks
| ------- | :--------: | :----------: | ----------- | -------
| Linux   | `x86_64`   | js           | node* |
| Linux   | `x86_64`   | js           | browser | [(1)](#toolchain_remark_browser)

* <a name="toolchain_remark_browser" /> *(1)* Runs under `phantomjs`, and if `SAUCE_USERNAME` and `SAUCE_ACCESS_KEY` are defined, runs under SauceLabs as well

##### TOOLCHAIN 
