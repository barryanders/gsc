# gsc
Search for words in YouTube videos and download them. This is not being maintained. I made it to find clips of people saying specific things, then I would edit the clips together to make them sing songs.

## Usage

### captions-dl.sh

Download captions for all videos on a channel by username. If you already downloaded the captions for a channel, you can just go straight to using `word-dl.sh`.
```bash
captions-dl.sh "username"
```

### word-dl.sh

Search the captions and download a clip if the content is found.
```bash
word-dl.sh "username" "word or phrase"
```
