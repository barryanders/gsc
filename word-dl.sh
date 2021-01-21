#!/usr/bin/env bash

# read -p 'Enter YouTube Channel: ' channel
channel=$1
# read -p 'Enter words or phrases: ' words
words=$2

# make the channel directory
mkdir -p ./channels/$channel

file="./channels/$channel/$words.mp4"

if [[ -f $file ]]; then
  echo Already have: '"'$words.mp4'"'! Skipping...
else
  echo; echo ------------------------------; echo
  echo "Searching $channel for: $words"

  # get video id and start time with search.js
  IFS=,
  set $(node search.js $channel "$words")

  if [ ! $2 = $words ]; then
    videoId=$1
    startTime=$2
    videoUrl=$(youtube-dl -f best --get-url https://www.youtube.com/watch?v=$videoId)

    # strip out anything that's not alphanumeric
    words=${words//[^a-zA-Z0-9 ]/}

    echo "Video Page: https://www.youtube.com/watch?v="$videoId
    echo "Start Time:" $startTime
    echo; echo ---; echo

    # -------------------------------------------------------------------------------------------------

    # download clips using ffmpeg and youtube-dl
    word_dl=(
      ffmpeg

      # URL
      # input file url
      # -f best or -f 22 or -f 137+140
      -i -

      # Start Time
      # Seeks in this input file to position.
      # Note that in most formats it is not possible to seek exactly, so ffmpeg will seek to the closest seek point before position. When transcoding and -accurate_seek is enabled (the default), this extra segment between the seek point and position will be decoded and discarded. When doing stream copy or when -noaccurate_seek is used, it will be preserved.
      -ss "$startTime"

      # Duration
      # Limit the duration of data read from the input file.
      -t "00:00:10"

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
      $file
    )

    # download clips using youtube-dl only
    word_dl2=(
      youtube-dl --continue --no-check-certificate

      # -ss: Start Time - Seeks in this input file to position.
      # -t: Duration - Limit the duration of data read from the input file.
      --postprocessor-args "-ss $startTime -t 00:00:10"

      # Output Dir
      --output $file

      # Video URL
      "https://www.youtube.com/watch?v=$videoId"
    )

    function run() {
      if [[ -f $file ]]; then
        echo Already exists! Skipping $file...
      else
        if [[ $videoUrl == '' ]]; then
          echo Video URL not found. Looking again...
          videoUrl=$(youtube-dl -f best --get-url https://www.youtube.com/watch?v=$videoId)
          echo; echo ---; echo
          run
        else
          echo Video URL found!; echo
          echo Video URL: $videoUrl; echo
          echo Downloading video...
          wget -O - "$videoUrl" | "${word_dl[@]}"
          if [[ -f $file ]]; then
            echo Done! $file;
          else
            echo Failed! $file;
            sleep 1;
            echo Retrying... $file;
            echo; echo ---; echo
            run
          fi
        fi
      fi
    }
    run
  else
    echo "Unable to find: $words"; echo
  fi
fi

# -------------------------------------------------------------------------------------------------
