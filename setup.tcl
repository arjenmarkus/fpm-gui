# setup.tcl --
#     Set up the combination fpm and fpm-gui:
#     Nothing more than copying out the files!
#
if { $::tcl_platform(platform) == "windows" } {
    console show
    wm withdraw .
}
foreach f [glob [file join [file dirname $::argv0] files]/*] {
    puts "Copying [file tail $f] ..."
    file copy -force $f .
}
puts "Done"

if { $::tcl_platform(platform) == "windows" } {
    puts "Closing this window in 5 seconds"
    after 5000 exit
}
