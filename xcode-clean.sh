#!/bin/sh

text_magenta=$(tput setaf 5)
text_bold=$(tput bold)
text_normal=$(tput sgr0)

archives_path=~/"Library/Developer/Xcode/Archives"
derived_data_path=~/"Library/Developer/Xcode/DerivedData"
simulator_data_path=~/"Library/Developer/CoreSimulator/Devices"
device_support_path=~/"Library/Developer/Xcode/iOS DeviceSupport"

remove_archives=false
remove_derived_data=false
remove_device_support=false
remove_simulator_data=false

backup_dsyms=false
dsym_backup_path=""
dry_run=false

remove_contents() {
    arg_path=$1
    arg_name=$2
    arg_flag_name=$3
    
    size=$(du -hcs "$arg_path" | tail -1 | cut -f1 | xargs)
    
    if $dry_run; then
        printf "Clearing $arg_name($arg_flag_name flag) in ${arg_path}/* would free up ${text_bold}${size}${text_normal} disk space\n"
    else
        printf "Clearing $arg_name in ${arg_path}/* (freeing ${text_bold}${size}${text_normal} disk space)\n"
        rm -Rf "$arg_path"/*
    fi
}

do_dsym_backup() {
    backup_path=$1
    
    cd "$archives_path"
    
    { find . -name "dSYMs" -exec printf '%s\0' {} + | while IFS= read -ru3 -d '' file; do
      dsym_backup_file "$file"; done 3<&0 <&4 4<&-; } 4<&0
}

dsym_backup_file() {
    path=$1
    absolute_path="${archives_path}/${path}"
    output_path="${backup_path}/${path}"
    output_path=$(dirname "$output_path")
    
    if $dry_run; then
        printf "Back up $absolute_path to $output_path\n"
    else    
        cd "$archives_path"
        printf "Backing up $absolute_path to $output_path \n"
        mkdir -p "$output_path" # Create dir(s) if it doesn't exist
        cp -R "$absolute_path" "$output_path"
    fi
}

usage() {
cat << EOF
Usage: $0 [options]

Frees up disk space by removing Xcode data. NOTE: you might want to keep backups of the dSYM files in ~/Library/Developer/Xcode/Archives

EXAMPLE:
    $0 -A

OPTIONS:
   -h           Show this help message
   -b [path]    Backup dSYM files to specified path before removing archives
   -a           Removed all Xcode archives
   -d           Remove everything in DerivedData folder
   -D           Remove everything in DeviceSupport folder
   -s           Remove simulator data
   -A           Remove all of the above(archived, DerivedData and simulator data)
   --dry-run    Dry run mode prints which directories would be cleared but don't remove any files

EOF
}

while getopts "hadDsAb:-:" OPTION
do
    case $OPTION in
    -)
        case "${OPTARG}" in
            dry-run)
                value="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                dry_run=true
                ;;
            *)
                if [ "$OPTERR" = 1 ] && [ "${optspec:0:1}" != ":" ]; then
                    usage
                    exit 1
                    #echo "Unknown option --${OPTARG}" >&2
                fi
                ;;
        esac;;
    h)
        usage
        exit 0
        ;;
    a)
        remove_archives=true
        ;;
    d)
        remove_derived_data=true
        ;;
    D)
        remove_device_support=true
        ;;
    s)
        remove_simulator_data=true
        ;;
    A)
        remove_archives=true
        remove_derived_data=true
        remove_device_support=true
        remove_simulator_data=true
        ;;
    b)
        backup_dsyms=true
        dsym_backup_path="$OPTARG"
        ;;
    \?)
        usage
        exit 1
        ;;
    esac
done

if $dry_run; then
    printf "${text_magenta}Running in dry run mode. No files will be removed.${text_normal}\n"
fi

if $backup_dsyms; then
    do_dsym_backup "$dsym_backup_path"
fi

if $remove_archives; then
    remove_contents "$archives_path" "archives" "-a"
fi

if $remove_derived_data; then
    remove_contents "$derived_data_path" "DerivedData content" "-d"
fi

if $remove_device_support; then
    remove_contents "$device_support_path" "iOS DeviceSupport content" "-D"
fi

if $remove_simulator_data; then
    remove_contents "$simulator_data_path" "simulator data" "-s"
fi
