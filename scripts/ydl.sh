#!/bin/bash

YOUTUBE_DL="/usr/local/bin/youtube-dl"
YOUTUBE_ETH="/home/ubuntu/tunes/ethiopian"
YOUTUBE_FORMAT="mp4"
ETH_LIST="https://www.youtube.com/playlist?list=PL7TV3mNaJdxR3Q-YX9jkdPwzluwDQOzY9"
HIP_LIST="https://www.youtube.com/playlist?list=PLtn2OGz1dPpMYUs0LM4A_CMUE5df849Eo"
#youtube-dl -i  -f mp4 https://www.youtube.com/playlist?list=PLtn2OGz1dPpMYUs0LM4A_CMUE5df849Eo
cd "$YOUTUBE_ETH"
$YOUTUBE_DL \
    --ignore-errors \
    -f "$YOUTUBE_FORMAT" \
    "https://www.youtube.com/playlist?list=PL7TV3mNaJdxR3Q-YX9jkdPwzluwDQOzY9"
