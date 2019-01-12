#!/usr/bin/env bash

# read -p 'Enter YouTube Channel: ' channel
channel=$1

echo "Looking for $channel captions…"
echo; echo ---; echo

mkdir -p channels/$channel/vtt
cd channels/$channel/vtt

# -------------------------------------------------------------------------------------------------

captions_dl=(
  youtube-dl
  # Basic Settings
  --id --continue --no-overwrites --ignore-errors --no-call-home --skip-download

  # Sub Settings
  --sub-lang          en
  --sub-format        vtt
  --convert-subtitles srt
  --write-sub
  --write-auto-sub

  # Match title filters the returned channel video list by title
  # --match-title trump

  # Input channel, playlist, or video
  https://www.youtube.com/$channel
)

"${captions_dl[@]}"

# -------------------------------------------------------------------------------------------------