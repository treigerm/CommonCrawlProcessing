load_config() {
    # Load variables from config file and export the ones which are needed in other
    # scripts. Only use the value from the config file if the variable hasn't been
    # set before.
    source "${1}"
    if [[ -z ${CRAWL_URL+x} ]]; then CRAWL_URL="$crawl_url"; fi
    if [[ -z ${WET_DIR+x} ]]; then WET_DIR="$wet_dir"; fi
    if [[ -z ${MONOLINGUAL_DIR+x} ]]; then MONOLINGUAL_DIR="$monolingual_dir"; fi
    if [[ -z ${DEDUPED_DIR+x} ]]; then DEDUPED_DIR="$deduped_dir"; fi
    if [[ -z ${LANGUAGES+x} ]]; then LANGUAGES="$languagesfile"; fi
    if [[ -z ${PREVIOUS_DEDUPED_DIR+x} ]]; then PREVIOUS_DEDUPED_DIR="$previous_deduped_dir"; fi
    export PREVIOUS_DEDUPED_DIR
}

print_help() {
    local APP="precc"
    cat <<EOF
Usage:
$APP [options] (setup|download|extract_monolingual|dedupe)...

-h, --help             display help
-u, --crawl-url        url to download the wet.paths.gz file for a given crawl
-W, --wet-dir          directory with downloaded WET data
-M, --monolingual-dir  directory to output data split according to language
-D, --deduped-dir      directory for output from deduper
-l, --languagesfile    file which specifies which languages to run the deduper on
-c, --config           custom configeration file
-j, --jobs             number of simultaneous jobs to run for GNU parallel
--progress             if selected GNU parallel will display progress
--sshloginfile         ssh file for GNU parallel
EOF
}

parse_args() {
    if [[ $# -eq 0 ]]; then
        # TODO: Check if this is appropriate behaviour especially when no commands means we do everything
        #       and we can set options from config.
        print_help
        exit 1
    fi

    # Parse arguments. Taken from
    # https://stackoverflow.com/questions/192249/how-do-i-parse-command-line-arguments-in-bash.
    local SHORT=hu:W:M:D:l:j:c:
    local LONG=help,crawl-url:,wet-dir:,monolingual-dir:,deduped-dir:,languagesfile:,sshloginfile:,jobs:,config:,progress

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
            -u|--crawl-url)
                CRAWL_URL="$2"
                shift 2
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
            --progress)
                PROGRESS="1"
                shift
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

    SETUP=0
    DOWNLOAD=0
    EXTRACT_MONOLINGUAL=0
    DEDUPE=0
    if [[ $# -eq 0 ]]; then
        SETUP=1
        DOWNLOAD=1
        EXTRACT_MONOLINGUAL=1
        DEDUPE=1
    else
        while [[ $# -gt 0 ]]; do
            case "$1" in
                setup)
                    SETUP=1
                    shift
                    ;;
                download)
                    DOWNLOAD=1
                    shift
                    ;;
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

    set_parallel_options
}

set_parallel_options() {
    PARALLEL_OPTIONS="--nice 19"
    if [[ "${PROGRESS}" -ne 0 ]]; then
        PARALLEL_OPTIONS="${PARALLEL_OPTIONS} --progress"
    fi
    if [[ ! -z "${SSHLOGINFILE}" ]]; then
        PARALLEL_OPTIONS="${PARALLEL_OPTIONS} --sshloginfile ${SSHLOGINFILE}"
    fi
    if [[ ! -z "${PARALLELJOBS}" ]]; then
        PARALLEL_OPTIONS="${PARALLEL_OPTIONS} -j ${PARALLELJOBS}"
    fi
}
