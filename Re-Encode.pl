
#$X265_QUALITY = 18; # Virtually lossless
$X265_QUALITY = 28; # Movies/Series
$X265_PRESET = 'medium'; # slower/slow/medium/fast/veryfast
$X265_MAX_BITRATE = 10000; # Kbit/s



processdir('.');

exit;

sub processdir {
	my($folder) = @_;
	
	my($DIR,$de,$suffix);
	
	opendir($DIR,$folder);
	foreach $de (readdir($DIR)) {
		next if ($de eq '.');
		next if ($de eq '..');
		
		if (-d $folder.'/'.$de) {
			processdir($folder.'/'.$de);
		} elsif ($de =~ /^(.+)\.(mp4|mkv|mov|avi|mpg|mpeg|wmv|m4v|flv|f4v)$/i) {
			$filename = $1;
			$suffix = $2;
			
			print 'File: '.$folder.'/'.$de;
			
			if ($de =~ /-ReEncode-$X265_QUALITY\.$suffix$/i) {
				# This file has been Re-encoded, skip
				print ' exist, skipping...'."\n";
				
			} elsif (-e ($folder.'/'.$filename.'-ReEncode-'.$X265_QUALITY.'.mp4')) {
				# Re-encoded file exist, skip
				print ' exist, skipping...'."\n";
				
			} else {
				# Re-encode

				print ' re-encoding...'."\n";
			
				`ffmpeg -y -i "$folder/$de" -c:v libx265 -crf $X265_QUALITY -preset $X265_PRESET -pix_fmt yuv420p10le -x265-params "pass=1:vbv-maxrate=$X265_MAX_BITRATE:vbv-bufsize=$X265_MAX_BITRATE" -an -f mp4 NUL`;
				
				`ffmpeg -y -i "$folder/$de" -c:v libx265 -crf $X265_QUALITY -preset $X265_PRESET -pix_fmt yuv420p10le -x265-params "pass=1:vbv-maxrate=$X265_MAX_BITRATE:vbv-bufsize=$X265_MAX_BITRATE" -c:a aac -b:a 128k -ac 2 "$folder/$filename-ReEncode-$X265_QUALITY.mp4"`;
				
				print "\n";
			}
		}
		
	}
	closedir($DIR);	
}
