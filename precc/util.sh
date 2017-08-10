load_config() {
    # TODO: Maybe use hypen instead of underscore?
    # Load variables from config file and export the ones which are needed in other
    # scripts. Only use the value from the config file if the variable hasn't been
    # set before.
    source "${1}"

    if [[ -z ${CRAWL_URL+x} ]]; then CRAWL_URL="$crawl_url"; fi
    if [[ -z ${BATCH_SIZE+x} ]]; then BATCH_SIZE="$batch_size"; fi
    if [[ -z ${DOWNLOAD_DIR+x} ]]; then DOWNLOAD_DIR="$download_dir"; fi
    if [[ -z ${MONOLINGUAL_DIR+x} ]]; then MONOLINGUAL_DIR="$monolingual_dir"; fi
    if [[ -z ${DEDUPED_DIR+x} ]]; then DEDUPED_DIR="$deduped_dir"; fi
    if [[ -z ${RAW_DIR+x} ]]; then RAW_DIR="$raw_dir"; fi
    if [[ -z ${CRAWL_ID+x} ]]; then CRAWL_ID="$crawl_id"; fi
    if [[ -z ${HASH_TABLE_DIR+x} ]]; then HASH_TABLE_DIR="$hash_table_dir"; fi
    if [[ -z ${LANGUAGES+x} ]]; then LANGUAGES="$languagesfile"; fi
    if [[ -z ${PREVIOUS_DEDUPED_DIR+x} ]]; then PREVIOUS_DEDUPED_DIR="$previous_deduped_dir"; fi
    export PREVIOUS_DEDUPED_DIR
    export DOWNLOAD_DIR
}

print_help() {
    local APP="precc"
    cat <<EOF
Usage:
$APP [options] (setup|download|dedupe|create_raw)...

-h, --help                  display help
-u, --crawl-url             url to download the wet.paths.gz file for a given crawl
-b, --batch-size            number of files in one crawl
-d, --download-dir          directory with downloaded data
-M, --monolingual-dir       directory to output data split according to language
-D, --deduped-dir           directory for output from deduper
-R, --raw-dir               directory to output raw files
-i, --crawl-id              CommonCrawl ID of the crawl as given in the form YEAR_WEEK
-H, --hash-table-dir        hash table for the deduper to read from disk
-p, --previous-deduped-dir  directory containing existing deduplicated files
-l, --languagesfile         file which specifies which languages to run the deduper on
-c, --config                custom configeration file
-j, --jobs                  number of simultaneous jobs to run for GNU parallel
--progress                  if selected GNU parallel will display progress
--sshloginfile              ssh file for GNU parallel
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
    local SHORT=hu:b:d:M:D:R:l:j:c:H:p:i:
    local LONG=help,crawl-url:,batch_size:,download-dir:,monolingual-dir:,deduped-dir:,raw-dir:,crawl-id:,hash-table-dir:,previous-deduped-dir:,languagesfile:,sshloginfile:,jobs:,config:,progress

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
            -b|--batch-size)
                BATCH_SIZE="$2"
                shift 2
                ;;
            -d|--download-dir)
                DOWNLOAD_DIR="$2"
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
            -R|--raw-dir)
                RAW_DIR="$2"
                shift 2
                ;;
            -i|--crawl-id)
                CRAWL_ID="$2"
                shift 2
                ;;
            -H|--hash-table)
                HASH_TABLE_DIR="$2"
                shift 2
                ;;
            -p|--previous-deduped-dir)
                PREVIOUS_DEDUPED_DIR="$2"
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
    DEDUPE=0
    CREATE_RAW=0
    if [[ $# -eq 0 ]]; then
        # TODO: Check wether this creates any problems.
        SETUP=1
        DOWNLOAD=1
        DEDUPE=1
        CREATE_RAW=1
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
                dedupe)
                    DEDUPE=1
                    shift
                    ;;
                create_raw)
                    CREATE_RAW=1
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
