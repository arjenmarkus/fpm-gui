# fpm-prepare.tcl --
#     Prepare the GUI:
#     - Get the up-to-date fpm-registry
#     - Make sure that the various directories exist
#

# getRegistry --
#     Get the registry and put it in the dedicated directory
#
# Arguments:
#     url             The URL to retrieve fpm-registry project
#     checkout        The checkout directory
#
# Note:
#     If this step fails, the program stops
#
proc getRegistry {url checkout} {
    set oldcwd   [pwd]
    set cloneDir [file tail $url]

    if { ! [file exists $checkout] } {
        if { [catch {
            file mkdir $checkout
        } msg] } {
            tk_messageBox -icon error -type ok -title "Fpm - preparation failed" \
                -message "Could not create the directory $checkout\nPlease specify a different name\nError: $msg"
            exit
        }
    }

    if { ! [file isdir $checkout] } {
        tk_messageBox -icon error -type ok -title "Fpm - preparation failed" \
            -message "$checkout is not a directory $checkout\nPlease specify a different name"
        exit
    }

    cd $checkout

    if { ! [file exists $cloneDir] } {
        set rc [catch {
            exec -ignorestderr git clone $url
        } msg]
    } else {
        set rc [catch {
            cd $cloneDir
            exec git fetch
            exec git merge --ff-only
        } msg]
    }
    if { $rc != 0 } {
        tk_messageBox -icon error -type ok -title "Fpm - preparation failed" \
            -message "Error cloning the fpm-registry\nPlease check this\nError: $msg"
        exit
    }

    if { ! [file exists [file join $checkout $cloneDir registry.toml]] } {
        tk_messageBox -icon error -type ok -title "Fpm - preparation failed" \
            -message "Could not clone the fpm-registry\nError: $msg"
        exit
    }

    cd $oldcwd
}

# checkDirectories --
#     Check that the various directories to store the source files and the installation exist
#
# Arguments:
#     checkoutDir     Directory for checking out the sources
#     installDir      Directory for installing the libraries and such
#
proc checkDirectories {checkoutDir installDir} {
    foreach dir [list $checkoutDir $installDir] text [list "checkout directory" "installation directory"] {
        if { ! [file exists $dir] } {
            set rc [catch {file mkdir $dir} msg]
            if { $rc != 0 } {
                tk_messageBox -icon error -type ok -title "Fpm - preparation failed" \
                    -message "Could not create the $text - $dir\nError: $msg"
                exit
            }
        } else {
            if { ! [file isdir $dir] } {
                tk_messageBox -icon error -type ok -title "Fpm - preparation failed" \
                    -message "$dir is not a directory\nPlease select a different $text"
                exit
            }
        }
    }
}

# test --
#getRegistry xxx e:/xyz
#getRegistry xxx d:/xyz
#getRegistry "https://github.com/fortran-lang/fpm-registry" d:/xyz
#checkDirectories c:/xyz d:/xyzz
#checkDirectories d:/xyzz d:/xyzz
