# fpm-gui

*fpm-gui* is a straigtforward user-interface to use the [fpm](https://github.com/fortran-lang/fpm) Fortran package manager
via a graphical user-interface instead of the commandline.

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)

It helps with the following tasks:

 * Retrieve the source code for a particular package
 * Build the package
 * Install the package for use in other programs or contexts

## Version

Current version: 0.1, dd. may 2021.

There are a lot of functions that are planned but not yet implemented.


## Supported platforms and required software

*fpm-gui* is built in Tcl/Tk and is thus a platform-independent user-interface. What is required is a Tcl/Tk runtime
environment for the platform, such as *wish* or *tclkit*.

The current, preliminary, version of *fpm-gui* relies on several external programs and program suites:

 * *git* - to retrieve the source code (in fact a clone of the packages will be created when you retrieve them).
 * *gfortran* - used as the (default) compiler. It is planned to support other Fortran compilers in later versions.
 * *xdg-open* - required on Linux-like platforms (also for Cygwin) for displaying web pages; on "plain" Windows this is taken care of in a different way.

Last but not least: *fpm* itself.

## Installation

Installation is straightforward:

 * Put the files in the repository in a subdirectory "fpm" under your home directory (in Windows this is probably `c:\users\<yourname>`)
 * Copy the fpm executable into the same directory

It will use the following directories for its operation (the tilde indicates the user's home directory):

 * `~/fpm` - installation directory
 * `~/fpm-packages` - to store the source for the packages in and to install the executables and libraries

You can start the GUI by running:

```
   wish ~/fpm/fpm-gui.tcl
```

*Note:* The installation directory `~/fpm` is used to store some temporary files, so it must be writeable.

*Note:* In a next version this procedure will be further simplified by providing a standalone executable per platform.

