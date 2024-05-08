continueOrAbort() {
    local message="$1"
    local aborting_message="$2"
    local return_instead="${3:-false}"

    echo -n "$message Are you sure you want to continue? (y/n) "
    read confirmation

    case "$confirmation" in
    n | N | no | No | NO | nope | Nope | NOPE)
        echo -e "\n$aborting_message\n"

        echo -n "Press any key to continue..."
        read whatever

        clear

        if [[ "$return_instead" ]]; then
            return 1
        else
            exit 1
        fi
        ;;
    esac
}
