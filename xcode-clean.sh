#!/bin/sh

archives_path=~/"Library/Developer/Xcode/Archives"
derived_data_path=~/"Library/Developer/Xcode/DerivedData"
simulator_data_path=~/"Library/Developer/CoreSimulator/Devices/"
device_support_path=~/"Library/Developer/Xcode/iOS DeviceSupport"

remove_archives=false
remove_derived_data=false
remove_device_support=false
remove_simulator_data=false

remove_contents() {
    arg_path=$1
    arg_name=$2
    
    size=$(du -hcs "$arg_path" | tail -1 | cut -f1 | xargs)
    
    printf "Removing $arg_name in ${arg_path}* (freeing $size disk space)\n"
    rm -R "$arg_path"/*
}

usage() {
cat << EOF
    Usage: $0 [options]

    Frees up disk space by removing Xcode data. NOTE: you might want to keep backups of the dsym files in ~/Library/Developer/Xcode/Archives
    
    EXAMPLE:
        $0 -A

    OPTIONS:
       -h      Show this help message
       -a      Removed all Xcode archives
       -d      Remove everything in DerivedData folder
       -D      Remove everything in DeviceSupport folder
       -s      Remove simulator data
       -A      Remove all of the above(archived, DerivedData and simulator data)

EOF
}

while getopts "hadDsA" OPTION
do
    case $OPTION in
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
        \?)
            usage
            exit 1
            ;;
    esac
done

if $remove_archives; then
    remove_contents "$archives_path" "archives"
fi

if $remove_derived_data; then
    remove_contents "$derived_data_path" "DerivedData content"
fi

if $remove_device_support; then
    remove_contents "$device_support_path" "iOS DeviceSupport content"
fi

if $remove_simulator_data; then
    remove_contents "$simulator_data_path" "simulator data"
fi
