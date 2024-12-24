# Video-ReEncode

Good for archiving mobile, GoPro, DJI, dashcam etc. videofiles. Re-encode with a double-click.

This script will traverse the script-folder recursively, looking for videofiles and re-encode them. Re-encoded files will be skipped, and files with a re-encoded counterpart will also be skipped.

Default settings:
* video: x265, audio: aac/128/stereo
* Two pass
* Medium profile
* Quality Setting of 22
* Max bitrate of 10000kbit/s

This will generally encode 1080p files with pretty much visually identical quality, but much smaller filesize. If you want even smaller files, and can accept small artifacts, adjust quality setting to 28.

# FFmpeg

FFMpeg is used for encoding. Download most recent version here:

[ffmpeg.org/download.html](https://ffmpeg.org/download.html)

For windows, unzip, and add folder containing ffmpeg.exe to windows PATH environment variable.

# Perl for windows

[strawberryperl.com](https://strawberryperl.com/)


