# maxmisc

Misc scripts and tools. Undocumented scripts probably do what I need them to but aren't finished yet.

## wanchors.sh | wanchplus.sh

Watches anchor files. If anchors are missing will shut down docker apps like plex to prevent library being emptied.
Use cron to run script at desired interval, eg minutely. Use wanchplus.sh to also restart those dockers and the merger.

`* * * * * /home/max/scripts/wanchors.sh`

## plex_futures.sh

Resets date added to plex to now if item was added as a future date.
Set DB Path and docker name variables before execution.

## plex_stuckers.sh

Resets date added to plex to airdate or premiere date.
Set DB Path and docker name variables before execution.
