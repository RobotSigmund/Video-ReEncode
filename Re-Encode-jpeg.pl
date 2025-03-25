
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
# 2= Virtually lossless
# 5= Small files, visually very close to identical
# 10= Even smaller files, but may generate visual artifacts
my $JPEG_QUALITY = 5;



# No need to edit below here



use strict;



# Print script path
print '['.$0.']'."\n";

# Start processing from the current directory
process_directory('.');

print 'Done'."\n";

<STDIN>;



exit;



sub process_directory {
	my($directory) = @_;
	
	opendir(my $DIR, $directory);
	foreach my $de (readdir($DIR)) {
		next if ($de =~ /^\.{1,2}$/);
		
		# Full path to the current directory entry
		my $entry_path = $directory.'/'.$de;
		
		if (-d $entry_path) {
			# This is a folder, call this routine recursively
			process_directory($entry_path);
			
		} elsif ($de =~ /^(.+)\.(jpg|jpeg|tif|bmp|gif)$/i) {
			# This is an imagefile

  			# Get filename and type from regex above
			my $filename = $1;
			my $suffix = $2;
			
			print 'File: '.$entry_path;
			
			if ($de =~ /-ReEncode-$JPEG_QUALITY\.$suffix$/i) {
				# This file has been Re-encoded, skip
				print ' re-encoded file, skipping...'."\n";
				
			} elsif (-e $directory.'/'.$filename.'-ReEncode-'.$JPEG_QUALITY.'.mp4') {
				# Re-encoded file exist, skip
				print ' allready re-encoded, skipping...'."\n";
				
			} else {
				# Re-encode

				print ' re-encoding...'."\n";
				my $cmd = 'ffmpeg -y -v error -stats -i "' . $entry_path . '" -q:v '.$JPEG_QUALITY.' "'.$directory.'/'.$filename.'-ReEncode-'.$JPEG_QUALITY.'.jpg"';
				`$cmd`;
				print "\n";
			}
		}
		
	}
	closedir($DIR);	
}
