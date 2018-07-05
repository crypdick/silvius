#!/bin/bash

action=$1
shift
args=$@

function check_microphone {
    if [[ -f .selected-mic ]]; then
        which=$(cat .selected-mic)
    else
        echo "No microphone selected..."
        echo "Finding microphones . . ."
        python2 stream/list-mics.py 2>/dev/null

        echo "Use which device?"
        read which
        echo $which >> .selected-mic
    fi
    echo "Selected microphone $which."
}

function run_recognition {
    if [[ $1 == 1 ]]; then
        python2 stream/mic.py -s silvius-server.voxhub.io -d $which $args | python2 grammar/main.py
    else
        python2 stream/mic.py -s silvius-server.voxhub.io -d $which $args
    fi
}

case "$action" in
    ''|-h|--help)
        echo "usage: $0 (-h|--help | -e|--execute | -t|--test | -d|--delete) [extra-args]"
        echo -e "\t-h|--help: prints this help message"
        echo -e "\t-e|--execute: executes results of speech recognition"
        echo -e "\t-t|--test: prints results of speech recognition"
        echo -e "\t-d|--delete: deletes saved microphone selection"
        echo -e "\t-G|--show-gate: displays audio level of background noise"
        ;;
    -t|--test)
        check_microphone
        run_recognition 0
        ;;
    -e|--execute)
        check_microphone
        run_recognition 1
        ;;
    -d|--delete)
        rm -f .selected-mic
        ;;
    -G|--show-gate)
        check_microphone
        python2 stream/audio-gate-level.py -d 6
        ;;
    *)
        echo "Unknown command '$action'. Run with --help to see usage."
        exit 1
        ;;
esac
