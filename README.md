# maxmisc
Misc scripts and tools.

## wanchors.sh

Watches anchor files. If anchors are missing will shut down docker apps like plex to prevent library being emptied.
Use cron to run script at desired interval, eg minutely.

`* * * * * /home/max/scripts/wanchors.sh`

## plex_futures.sh
Reseets date added to plex to now if item was added as a future date.

## plex_stuckers.sh
Reseets date added to plex to airdate or premiere date.
