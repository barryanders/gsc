#!/usr/bin/env bash

# read -p 'Enter YouTube Channel: ' channel
channel=$1
# read -p 'Enter words or phrases: ' words
words=$2

echo "Searching $channel for: $words"
echo; echo ---; echo

# make the channel directory
mkdir -p ./channels/$channel

# get video id and start time with search.js
IFS=,
set $(node search.js $channel "$words")

if [ ! $2 = $words ]
then
  videoId=$1
  startTime=$2

# strip out anything that's not alphanumeric
words=${words//[^a-zA-Z0-9 ]/}

# -------------------------------------------------------------------------------------------------

  # download clips
  word_dl=(
    ffmpeg

    # URL
    # input file url
    -i $(youtube-dl -f 22 --get-url "https://www.youtube.com/watch?v=$videoId")

    # Start Time
    # Seeks in this input file to position.
    # Note that in most formats it is not possible to seek exactly, so ffmpeg will seek to the closest seek point before position. When transcoding and -accurate_seek is enabled (the default), this extra segment between the seek point and position will be decoded and discarded. When doing stream copy or when -noaccurate_seek is used, it will be preserved.
    -ss $startTime

    # Duration
    # Limit the duration of data read from the input file.
    -t 00:00:10

    # Frames Per Second
    # Set frame rate (Hz value, fraction or abbreviation).
    -r 30

    # Constant Rate Factor
    # The range of the CRF scale is 0–51, where 0 is lossless, 23 is the default, and 51 is worst quality possible.
    # A lower value generally leads to higher quality, and a subjectively sane range is 17–28. Consider 17 or 18 to be visually lossless or nearly so; it should look the same or nearly the same as the input but it isn't technically lossless.
    -crf 15.0

    # Video Codec
    -vcodec libx264

    # Audio Codec
    -acodec aac

    # Overwrite output files. (-y for yes, -n for no)
    -n

    # Output Dir
    "./channels/$channel/$words.mp4"
  )

  "${word_dl[@]}"

# -------------------------------------------------------------------------------------------------

else
  echo "Unable to find: $words"; echo
fi
