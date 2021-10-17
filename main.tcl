# main.tcl --
#     Very light wrapper around the actual main program
#
package require Tk
source [file join [file dirname $::argv0] fpm-gui.tcl]
