# xcode-clean.sh
Bash script freeing up disk space by removing Xcode generated data

## Usage
```
$ ./xcode-clean.sh -h
    Usage: ./xcode-clean.sh [options]

    Frees up disk space by removing Xcode data. NOTE: you might want to keep backups of the dsym files in ~/Library/Developer/Xcode/Archives
    
    EXAMPLE:
        ./xcode-clean.sh -A

    OPTIONS:
       -h      Show this help message
       -a      Removed all Xcode archives
       -d      Removed everything in DerivedData folder
       -s      Remove simulator data
       -A      Remove all of the above(archived, DerivedData and simulator data)
```
