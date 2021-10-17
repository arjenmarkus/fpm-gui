# fpm-menu.tcl --
#     Implement the menu items
#

# showInformation
#     Show the general information on fpm
#
# Arguments:
#     None
proc showInformation {} {
    global fpmInformation

    showPkgInformation 0

    tk_messageBox -icon info -type ok -title "Fpm - Fortran package manager" \
        -message "The package manager is found at $fpmInformation"
}

# showAboutBox
#     Show the general information on fpm
#
# Arguments:
#     None
proc showAboutBox {} {
    global fpmGuiVersion
    global fpmCommand

    set fpmVersion [exec $fpmCommand --version]

    tk_messageBox -icon info -type ok -title "Fpm - Fortran package manager" \
        -message \
"$fpmVersion\n
GUI version: $fpmGuiVersion"
}

# saveProfile --
#     Save the settings in a profile file
#
# Arguments:
#     new              Whether to save under a new name or not
#
proc saveProfile {new} {
    global profileName
    global installDir
    global checkoutDir
    global registryDir
    global compiler
    global compilerProfile

    if { $new || $profileName == "" } {
        set newProfileName [tk_getSaveFile -title "Save profile as ..." -filetypes [list {{fpm profile} {.profile}}] -initialfile $profileName]

        if { $newProfileName != "" } {
            set profileName $newProfileName
        }
    }

    set outfile [open $profileName w]

    foreach value {installDir checkoutDir registryDir } {
        puts $outfile "set $value [file normalize [set $value]]"
    }
    foreach value {compiler compilerProfile} {
        puts $outfile "set $value [set $value]"
    }

    close $outfile
}

# openProfile --
#     Open an existing profile file
#
# Arguments:
#     None
#
proc openProfile {} {
    global profileName

    set newProfileName [tk_getOpenFile -title "Open profile" -filetypes [list {{fpm profile} {.profile}}] -initialfile $profileName]

    if { $newProfileName != "" } {
        set profileName $newProfileName
        source $profileName
    }
}

# newProfile --
#     Create a new profile file
#
# Arguments:
#     None
#
proc newProfile {} {
    global profileName

    set profileName "" ;# Force a Save to bring up a dialogue
}
