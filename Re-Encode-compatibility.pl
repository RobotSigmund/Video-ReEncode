
# MIT License
#
# Copyright (c) 2025 Sigmund Straumland
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.



# Quality setting
# 20= Virtually lossless
# 24= Small files, visually very close to identical
# 30= Even smaller files, but may generate visual artifacts
my $X264_QUALITY = 31;

# X265 preset
# For high compatibility and ease of decoding I've set this to 'veryfast'.
my $X264_PRESET = 'veryfast'; # slower/slow/medium/fast/veryfast

# Max bitrate, you may want to increase this for higher resolutions like 4K
my $X264_MAX_BITRATE = 10_000_000; # 10 Mbit/s



# No need to edit below here



use strict;
use Cwd;


# Print current active path
print '[' . cwd() . ']' . "\n";

# Start processing from the current directory
process_directory('.');

print 'Done' . "\n";

<STDIN>;



exit;



sub process_directory {
	my($directory) = @_;
	
	opendir(my $DIR, $directory);
	foreach my $de (readdir($DIR)) {
		next if ($de =~ /^\.{1,2}$/);
		
		# Full path to the current directory entry
		my $entry_path = $directory . '/' . $de;
		
		if (-d $entry_path) {
			# This is a folder, call this routine recursively
			process_directory($entry_path);
			
		} elsif ($de =~ /^(.+)\.(mp4|mkv|mov|avi|mpg|mpeg|wmv|m4v|flv|f4v|vob|divx)$/i) {
			# This is a videofile

  			# Get filename and type from regex above
			my $filename = $1;
			my $suffix = $2;
			
			print 'File: ' . $entry_path;
			
			if ($de =~ /-ReEncode-\d+(-noaudio)?\.$suffix$/i) {
				# This file has been Re-encoded, skip
				print ' re-encoded file, skipping...' . "\n";
				
			} elsif (-e $directory . '/' . $filename . '-ReEncode-' . $X264_QUALITY . '.mp4') {
				# Re-encoded file exist, skip
				print ' allready re-encoded, skipping...' . "\n";
				
			} else {
				# Re-encode

				print ' re-encoding...'."\n";
				my $cmd = 'ffmpeg -y -v error -stats -i "' . $entry_path . '" -c:v libx264 -crf ' . $X264_QUALITY . ' -preset ' . $X264_PRESET . ' -profile:v main -level 4.1 -maxrate ' . $X264_MAX_BITRATE . ' -bufsize ' . ($X264_MAX_BITRATE * 2) . ' -pix_fmt yuv420p -c:a aac -b:a 128k -ac 2 -profile:a aac_low "' . $directory . '/' . $filename . '-ReEncode-' . $X264_QUALITY . '.mp4"';

				`$cmd`;
				print "\n";
			}
		}
		
	}
	closedir($DIR);	
}
