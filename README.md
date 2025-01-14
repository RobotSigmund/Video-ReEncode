# Video-ReEncode

Good for archiving mobile, GoPro, DJI, dashcam etc. videofiles. Re-encode with a double-click.

This script will traverse the script-folder recursively, looking for videofiles and re-encode them. Re-encoded files will be skipped, and files with a re-encoded counterpart will also be skipped.

Default settings:
* Container: MP4, video: x265, audio: aac/128/stereo
* Two pass
* Medium profile
* Quality Setting of 28
* Max bitrate of 10000Kbit/s

This will generally encode 1080p files with minor artifacts quality wise. A setting of 22 will produce allmost identical quality, but much smaller filesize than any mobile or camera will generate. For as good as lossless and identical quality choose 18.

Note: For 4k footage you may want to increase max bitrate setting, however it will most likely be just fine at 10K.

# FFmpeg

FFMpeg is used for encoding. Download most recent version here:

[ffmpeg.org/download.html](https://ffmpeg.org/download.html)

For windows, unzip, and add folder containing ffmpeg.exe to windows PATH environment variable.

# Perl for windows

[strawberryperl.com](https://strawberryperl.com/)


