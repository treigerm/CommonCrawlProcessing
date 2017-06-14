parse_args() {
    if [[ $# -eq 0 ]]; then
        # TODO: Check if this is appropriate behaviour especially when no commands means we do everything
        #       and we can set options from config.
        print_help
        exit 1
    fi

    # Parse arguments. Taken from
    # https://stackoverflow.com/questions/192249/how-do-i-parse-command-line-arguments-in-bash.
    local SHORT=hW:M:D:l:j:c:
    local LONG=help,wet-dir:,monolingual-dir:,deduped-dir:,languagesfile:,sshloginfile:,jobs:,config:

    # -temporarily store output to be able to check for errors
    # -activate advanced mode getopt quoting e.g. via “--options”
    # -pass arguments only via   -- "$@"   to separate them correctly
    local PARSED=$(getopt --options $SHORT --longoptions $LONG --name "$0" -- "$@")
    if [[ $? -ne 0 ]]; then
        exit 1
    fi
    # use eval with "$PARSED" to properly handle the quoting
    eval set -- "$PARSED"

    # now enjoy the options in order and nicely split until we see --
    while true; do
        case "$1" in
            -h|--help)
                print_help
                exit 0
                ;;
            -W|--wet-dir)
                WET_DIR="$2"
                shift 2
                ;;
            -M|--monolingual-dir)
                MONOLINGUAL_DIR="$2"
                shift 2
                ;;
            -D|--deduped-dir)
                DEDUPED_DIR="$2"
                shift 2
                ;;
            -l|--languagesfile)
                LANGUAGES="$2"
                shift 2
                ;;
            -c|--config)
                CONFIGFILE="$2"
                shift 2
                ;;
            -j|--jobs)
                PARALLELJOBS="$2"
                shift 2
                ;;
            --sshloginfile)
                SSHLOGINFILE="$2"
                shift 2
                ;;
            --)
                shift
                break
                ;;
            *)
                echo "Unexpected error"
                exit 1
                ;;
        esac
    done

    EXTRACT_MONOLINGUAL=0
    DEDUPE=0
    if [[ $# -eq 0 ]]; then
        EXTRACT_MONOLINGUAL=1
        DEDUPE=1
    else
        while [[ $# -gt 0 ]]; do
            case "$1" in
                extract_monolingual)
                    EXTRACT_MONOLINGUAL=1
                    shift
                    ;;
                dedupe)
                    DEDUPE=1
                    shift
                    ;;
                *)
                    ;;
            esac
        done
    fi

    # TODO: Have base string and then append to it.
    if [[ ${SSHLOGINFILE} ]]; then
        PARALLEL_OPTIONS="--nice 19 --progress --sshloginfile ${SSHLOGINFILE} -j ${PARALLELJOBS}"
    else
        PARALLEL_OPTIONS="--nice 19 --progress -j ${PARALLELJOBS}"
    fi
}
