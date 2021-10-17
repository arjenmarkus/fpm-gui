@echo off
rem
rem Straightforward build script to create a standalone executable for the GUI itself
rem and subsequently a self-extracting executable for "installing" fpm and fpm-gui
rem

echo First step ... create the standalone executable for the GUI
md fpm-gui.vfs
copy /y *.tcl fpm-gui.vfs
copy favicon.ico fpm-gui.vfs
tclkitsh sdx.kit wrap fpm-gui.exe -runtime tclkit.exe

echo Second step ... create the self-extracting executable
md fpm-setup.vfs
md fpm-setup.vfs\files
copy setup.tcl fpm-setup.vfs\main.tcl
copy fpm-gui.exe fpm-setup.vfs\files
copy fpm.exe fpm-setup.vfs\files
copy run.bat fpm-setup.vfs\files
tclkitsh sdx.kit wrap fpm-setup.exe -runtime tclkit.exe

echo Done - fpm-setup.exe ready
