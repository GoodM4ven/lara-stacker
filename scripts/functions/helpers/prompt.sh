prompt() {
    # ? Take in the arguments
    local first_sentence="$1"
    local second_sentence="${2:-}"
    local cancel_suppression="${3:-true}"
    local should_exit="${4:-true}"
    local without_warning="${5:-false}"

    local mute=""
    if [ "$cancel_suppression" == "false" ]; then
        mute=">&3"
    fi

    # ? Display the error or warning
    error_or_warning="Error: "
    if [ "$should_exit" == "false" ]; then
        error_or_warning="Warning: "
    fi
    if [ "$without_warning" == true ]; then
        eval echo -e \"\\n$first_sentence\\n\" $mute
    else
        eval echo -e \"\\n$error_or_warning $first_sentence\\n\" $mute
    fi

    # ? Display a tip if available
    if [[ -n $second_sentence ]]; then
        eval echo -e \"Tip: $second_sentence\\n\" $mute
    fi

    # ? Exit the script or not
    exit_or_continue="exit"
    if [ "$should_exit" == "false" ]; then
        exit_or_continue="continue"
    fi
    eval echo -ne \"Press any key to $exit_or_continue...\" $mute
    read -r whatever </dev/tty

    eval clear $mute

    if [ "$should_exit" == "true" ]; then
        exit 1
    fi
}
