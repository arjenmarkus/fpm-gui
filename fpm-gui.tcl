# fpm-gui.tcl --
#     Humble beginnings of a GUI for fpm
#
#     I may need to use TWAPI to suppress the spurious windows that the compiler produces:
#     https://twapi.magicsplat.com/v4.5/process.html#create_process
#
#     TODO:
#     multiple commands in runCommand to update an existing source directory
#
#

# Default settings --
set startDir    "~/fpm"
set tomlFile    "~/fpm/fpm-registry/registry.toml"
set fpmCommand  "~/fpm/fpm.exe"
set installDir  "~/fpm-packages/lib"
set checkoutDir "~/fpm-packages/src"
set registryUrl "https://github.com/fortran-lang/fpm-registry"
set registryDir "~/fpm"

if { [file exists "fpm-gui.profile"] } {
    source fpm-gui.profile
}

# Note: not entirely robust ...
foreach var [list startDir tomlFile fpmCommand installDir checkoutDir registryDir] {
    if { [string range [set $var] 0 1] eq "~/" } {
        set $var [file join $env(HOME) [string range [set $var] 2 end]]
    }
}

# loadRegistry --
#     Read the list of packages
#
# Arguments:
#     tomlfile      Name of the toml file to be loaded
#
# Result:
#     Dictionary of the packages and their Internet location
#
proc loadRegistry {tomlfile} {

    #
    # Make sure we have a registry file
    #
    getRegistry $::registryUrl $::registryDir

    #
    # Read it to fill the list of packages
    #
    if { ! [file exist $tomlfile] } {
        return [dict create]
    }

    set packageList [dict create]

    set infile [open $tomlfile]

    while { [gets $infile line] >= 0 } {
        if { [string index $line 0] == "\[" } {
            set name [string range $line 1 end-1]

            gets $infile line
            set line [string trim $line]

            if { [string index $line 0] == "\"" } {
                set url [lindex [split $line \"] 3]
            } else {
                set url [lindex [split $line \"] 1]
            }

            dict append packageList $name $url
        }
    }

    close $infile

    return $packageList
}

# runCommand --
#     Run a command and show the output in the text window
#
# Arguments:
#     cmdtype      What command to run
#
proc runCommand {cmdtype} {
    global checkoutDir
    global installDir
    global fpmCommand
    global selectedPackage
    global packageList

    set url     [dict get $packageList $selectedPackage]
    set workDir [file tail $url]

    if { $::tcl_platform(platform) eq "windows" } {
        set run [file join [file dirname $::argv0] run.bat]
    } else {
        set run ""
    }

    switch -- $cmdtype {
        "retrieve" {
            cd $checkoutDir
            if { ! [file exists $workDir] } {
                set cmd "git clone $url.git"
            } else {
                set cmd "git fetch; git merge --ff-only"
            }
        }
        "build"    {
            cd [file join $checkoutDir $workDir]
            set cmd [string map {/ "\\\\"} "$run $fpmCommand build"]
        }
        "install"  {
            cd [file join $checkoutDir $workDir]
            set cmd [string map {/ "\\\\"} "$run $fpmCommand install --prefix $installDir "]
        }
    }

    .textw.text insert end "Package: $selectedPackage -- location: $url\n\n" pkg

    set infile [open "|$cmd 2>@1" "r"]
    fconfigure $infile -buffering line
    fileevent $infile readable [list getInput $infile]
}

# getInput --
#     Get the text that an external program writes to stdout/stderr
#
# Arguments:
#     channel        Channel to the external program
#
# Returns:
#     Nothing
#
proc getInput {channel} {

    if { [gets $channel line] >= 0 } {
        #puts $logfile $line
        .textw.text insert end "$line\n"
        .textw.text see end
    } elseif { [eof $channel] } {
        catch {
            close $channel
            cd $::startDir
            .textw.text insert end "\nDone\n" pkg
            .textw.text see end
        }
    }
}

# showPkgInformation --
#     Show information on the selected package by opening the web page
#
# Arguments:
#     None
#
# Note:
#     For the moment this works on Windows only
proc showPkgInformation {} {
    global selectedPackage
    global packageList

    set outfile [open "index.html" w]
    puts $outfile [string map [list URL [dict get $packageList $selectedPackage]] {
<html>
<head>
<title>Package information</title>
<meta http-equiv="refresh" content="0; url=URL" />
</head>
<body>
<p>Information can be found here at <a href="URL">the package's home page</a></p>
</body>}]
    close $outfile

    if { $::tcl_platform(platform) eq "windows" } {
        exec cmd /c index.html &
    } else {
        exec xdg-open index.html
    }
}

# stopProgram --
#     Stop the program (for now: simply quit)
#
# Arguments:
#     None
#
proc stopProgram {} {
    exit
}

# mainWindow --
#     Set up the main window
#
# Arguments:
#     packageNames          List of package names
#
proc mainWindow {packageNames} {
    wm title      . "fpm - Fortran package manager"
    wm protocol   . WM_DELETE_WINDOW {stopProgram}


    catch { wm iconbitmap . [file join [file dirname $::argv0] "favicon.ico"] }

    menu  .menuBar -tearoff 0

    menu  .menuBar.file    -tearoff 0
    menu  .menuBar.options -tearoff 0
    menu  .menuBar.help    -tearoff 0

    .menuBar add cascade -label "File"    -underline 0 -menu .menuBar.file
    .menuBar add cascade -label "Options" -underline 0 -menu .menuBar.options
    .menuBar add cascade -label "Help"    -underline 0 -menu .menuBar.help

    menu .menuBar.file.menu    -tearoff 0
    menu .menuBar.options.menu -tearoff 0

    .menuBar.file add command -label "New" -command "newProfile" -underline 0
    .menuBar.file add command -label "Open" -command "openProfile" -underline 0
    .menuBar.file add separator
    .menuBar.file add command -label "Save" -command [list saveProfile 0] -underline 0 -accelerator "Ctrl-S"
    .menuBar.file add command -label "Save as ..." -command [list saveProfile 1]
    .menuBar.file add separator

    .menuBar.file add command -label "Exit" -command "stopProgram" -underline 0 \
         -accelerator "Alt-F4"

    .menuBar.options add command -label "Directories" -command "selectDirectories"    -underline 0
    .menuBar.options add command -label "Compiling"   -command "selectCompileOptions" -underline 0

    .menuBar.help    add command -label "Information" -command "showInformation"      -underline 0
    .menuBar.file add separator
    .menuBar.help    add command -label "About"       -command "showAboutBox"         -underline 0

    ttk::frame .packages
    grid [::ttk::label    .packages.label   -text "Available packages:"] \
         [::ttk::combobox .packages.pkglist -width 30 -textvariable selectedPackage -values $packageNames] -sticky news -pady 3 -padx 3
    grid .packages -sticky news

    ttk::frame .buttons
    grid [::ttk::button .buttons.retrieve -text "Retrieve"     -command [list runCommand retrieve]] \
         [::ttk::button .buttons.build    -text "Build"        -command [list runCommand build]]    \
         [::ttk::button .buttons.install  -text "Install"      -command [list runCommand install]] \
         [::ttk::button .buttons.info     -text "Information"  -command [list showPkgInformation]] -sticky news -padx 3
    grid .buttons -sticky news

    grid [::ttk::label    .empty1           -text ""] -sticky news
    grid [::ttk::label    .output           -text "Output of commands:"] -sticky news -pady 3 -padx 3
    ttk::frame .textw
    grid .textw - -sticky news -padx 3

    ttk::scrollbar .textw.scrollx -orient horiz -command ".textw.text xview"
    ttk::scrollbar .textw.scrolly               -command ".textw.text yview"
    text      .textw.text    -yscrollcommand ".textw.scrolly set" \
                             -xscrollcommand ".textw.scrollx set" \
                             -font "courier 10" -wrap none \
                             -foreground black

    grid      .textw.text    .textw.scrolly
    grid      .textw.scrollx x
    grid      .textw.text    -sticky news
    grid      .textw.scrolly -sticky ns
    grid      .textw.scrollx -sticky ew

    grid rowconfigure    .textw 2 -weight 1
    grid columnconfigure .textw 0 -weight 1

    .textw.text configure -wrap none

    . configure -menu .menuBar

    .textw.text tag configure pkg -foreground blue

    .textw.text insert end \
"Start up complete:
Checkout directory: $::checkoutDir
Installation directory: $::installDir\n
Number of registered packages: [llength $::packageNames]\n"

}

# main --
#
#set tomlfile "../fpm-registry/registry.toml"
#set fpmCommand "../fpm/fpm.exe"

# TODO: necessary to set it to something else?
set startDir [file dirname $::argv0]
source [file join $startDir fpm-prepare.tcl]

set packageList [loadRegistry $tomlFile]

#
# Make sure the directories for checking out and installation exist
#
checkDirectories $checkoutDir $installDir

#
# Set up the main window
#
set packageNames [dict keys $packageList]
set selectedPackage [lindex $packageList 0]

#foreach p [dict keys $packageList] {
#    #puts "$p -- [dict get $list $p]"
#    lappend packageNames [dict get $packageList $p]
#}

mainWindow $packageNames

if { $::tcl_platform(platform) eq "windows" } {
    console show
}
