Wrapping the stuff into a standalone program:

- Use tclkit without Tk - tclkitsh - for Windows: http://www.rkeene.org/devel/kitcreator/kitbuild/nightly/tclkit-8.6.11-win64-amd64-notk-xcompile
                                     for Linux: http://www.rkeene.org/devel/kitcreator/kitbuild/nightly/tclkit-8.6.11-linux-amd64
                                     for Mac OS X: no version available without Tk

- Use tclkit with Tk - tclkit - for Windows: http://www.rkeene.org/devel/kitcreator/kitbuild/nightly/tclkit-8.6.11-win64-amd64-xcompile
                                for Linux: http://www.rkeene.org/devel/kitcreator/kitbuild/nightly/tclkit-8.6.11-linux-amd64
                                for Mac OS X: http://tclkits.rkeene.org/fossil/raw/tclkit-8.6.3-macosx10.5-ix86+x86_64?name=1b4a7ae47ebab6ea9e0e16af4d8714c8b4aa0ce2

- Use sdx.kit - https://chiselapp.com/user/aspect/repository/sdx/uv/sdx-20110317.kit
  Rename to sdx.kit

Note:

- On Windows there are two separate configurations, one with and one
  without Tk. Since the Tk-enabled version presents a GUI when running,
  this one should NOT be used for automated packaging.

- On any system you can build an executable for any other system by
  selecting the right runtime.

Commands:

cp *.tcl fpm-gui.vfs
tclkitsh sdx.kit wrap fpm-gui.exe -runtime tclkit

Note:

- The extension ".exe" is platform-dependent
- Use the tclkit runtime executable for the selected platform

