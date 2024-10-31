continueOrAbort() {
    # ? Take in the arguments
    local message="$1"
    local aborting_message="$2"
    local cancel_suppression="${3:-true}"
    local return_instead="${4:-false}"

    local mute=""
    if [ "$cancel_suppression" == "false" ]; then
        mute=">&3"
    fi

    eval echo -ne \"\\n$message Are you sure you want to continue? \(y/n\) \" $mute
    read -r confirmation </dev/tty

    case "$confirmation" in
    n | N | no | No | NO | nope | Nope | NOPE)
        eval echo -ne \"\\n$aborting_message\\n\" $mute

        eval echo -ne \"\\nPress any key to continue...\" $mute
        read -r whatever </dev/tty

        eval clear $mute

        if [[ "$return_instead" == true ]]; then
            return 1
        else
            exit 1
        fi
        ;;
    esac
}
