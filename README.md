## Re-Encode.pl

Will search recursively for videofiles in script directory and encode a new version of each videofile with selected settings and filename-suffix "ReEncode-<n>".

Good for archiving mobile, GoPro, DJI, dashcam etc. videofiles. Re-encode with a double-click.

This script will traverse the script-folder recursively, looking for videofiles and re-encode them. Re-encoded files will be skipped, and files with a re-encoded counterpart will also be skipped.

Default settings:
* Container: MP4, video: x265, audio: aac/128/stereo
* Fast profile
* Quality Setting of 28
* Max bitrate of 10Mbit/s

This will generally encode 1080p files with minor artifacts quality wise. A setting of 22 will produce allmost identical quality, but much smaller filesize than any mobile or camera will generate. For as good as lossless and identical quality choose 18.

Note: For 4k footage you may want to increase max bitrate setting, however it will most likely be just fine at 10K.

Read more about x265 encoding here: [Anime Encoding Guide for x265 (HEVC) & AAC/OPUS (and Why to Never Use FLAC)](https://kokomins.wordpress.com/2019/10/10/anime-encoding-guide-for-x265-and-why-to-never-use-flac/)

More recommendations for bitrates and resolutions: [YouTube recommended upload encoding settings](https://support.google.com/youtube/answer/1722171?sjid=181486248341066613-EU)

## Extract-Frames.pl

All videoframes of the first found video in the script folder will be stored in a new folder with the same name as the video file.

Useful for AI upscaling with stable-diffusion.

## Thumbnails.pl

Creates a "screens" folder in the script folder and an image containing <n> thumbnails of any found videofiles.

## FFmpeg

FFMpeg is used for encoding. Download most recent version here:

[ffmpeg.org/download.html](https://ffmpeg.org/download.html)

For windows, unzip, and add folder containing ffmpeg.exe to windows PATH environment variable.

## Perl for windows

[strawberryperl.com](https://strawberryperl.com/)


