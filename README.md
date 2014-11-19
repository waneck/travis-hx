# travis-hx
[![Build Status](https://travis-ci.org/waneck/travis-hx.svg?branch=master)](https://travis-ci.org/waneck/travis-hx)
[![Build status](https://ci.appveyor.com/api/projects/status/iijaet0v30x55b7u)](https://ci.appveyor.com/project/waneck/travis-hx)

Helpers (and wikis) to easily test haxe code on travis. These scripts are an abstraction from @andyli's work on getting Travis to work with all Haxe targets

## Quickstart

### Travis
Copy `travis-example.yml` to your project as `.travis.yml`, customize as needed.

### Appveyor
Copy `appveyor-example.yml` to your project as `appveyor.yml`, customize as needed.

## Environment variables
The following environment variables are sensitive by the script runtime:

### TARGET
Defines the setup to be configured. This has exactly a 1:1 correspondence with the haxe target defined by the command-line

### TARGET_DIR
The target file (or directory) as specified by the haxe build.

### HXFLAGS
If you decide to build using hx-travis' build scripts, use this flag to configure the flags used to call the haxe compiler

### HXFLAGS_EXTRA
Again if you decide to build using hx-travis' build scripts, you can use this flag to determine target-specific options. Please note that if you override this you must include the target path and name. For example, if you want `-D nodejs` on a js app, you need to set HXFLAGS_EXTRA AS `HXFLAGS_EXTRA=" -D nodejs -js js.js"`

### OS and ARCH
Defines the OS and architecture to be used as test. The following combinations may be used:

| ARCH    |    OS    | Description      |  Implemented targets                                  |
| ------  | -------- | ---------------- | ----------------------------------------------------- |
| x86_64* | Linux    | 64-bit           | all; flash is always 32-bit
| x86_64* | Mac      | 64-bit           | all; flash is always 32-bit
| i686    | Linux    | 32-bit           | haxe, neko, js (node and phantomjs), php
| i686    | Mac      | 32-bit           | none
| i686    | Windows  | 32-bit (AppVeyor)| haxe, neko, cpp, java, cs, js (node only)
| x86_64  | Windows  | 64-bit (AppVeyor)| cpp, java(default), cs(default)

### TOOLCHAIN
If applicable, specifies a custom toolchain to be used for building / running. Default is always `default`

|   OS    |    ARCH    |    TARGET    |  TOOLCHAIN  | Remarks
| ------- | :--------: | :----------: | ----------- | -------
| Linux   | `x86_64`   | js           | node* |
| Linux   | `x86_64`   | js           | browser | [(1)](#toolchain_remark_browser)

* <a name="toolchain_remark_browser" /> *(1)* Runs under `phantomjs`, and if `SAUCE_USERNAME` and `SAUCE_ACCESS_KEY` are defined, runs under SauceLabs as well

### EVAL_TEST_CMD
On non-sys platforms (example: flash, browser javascript, etc), the exit code can't be used to determine if a test ended successfully or not. Instead, the program at `EVAL_TEST_CMD` environment variable will be used. If no program is defined, [the default program](extra/evaluate-test/EvalTest.hx) will be used. This will work with both utest (if compiling with `-D travis`) and buddy (if compiling with `-D reporter=buddy.reporting.TravisHxReporter`). Please note that you can fool the eval test quite easily for now - for example by tracing `success: true` while in a test.

## TODOs
Some functionality that are still to be implemented. Pull requests are very welcome:

 * toolchain: cpp - android
 * toolchain: cpp - iOs
 * toolchain: cpp - clang
 * Haxe 3.0 / 3.2 / 2.10 toolchains (allow to not use always the latest haxe)
 * Neko 1.8 / 2.0

