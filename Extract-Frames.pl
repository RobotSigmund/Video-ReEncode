
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
my $CFG_PNG_COMPRESSION = 8; # [1-31]



# No need to edit below here



use strict;
use Cwd;


# Print current active path
print '[' . cwd() . ']' . "\n";

# Find the first available media file in the script folder
my $file;
my $filename;
my $filetype;
opendir(my $DIR, '.');
foreach my $de (readdir($DIR)) {
	if ($de =~ /^(.+)\.(mp4|mkv|mov|avi|mpg|mpeg|wmv|m4v|flv|f4v|vob|divx)$/i) {
		# Found one, select this file
		$filename = $1;
		$filetype = $2;
		$file = $de;
		print 'File: ' . $de . ' working...' . "\n";
		last;
	}
	
}
closedir($DIR);

# Create folder for all the frames
mkdir($filename) or die 'ERROR: Could not create "' . $filename . '" folder' . "\n" unless (-d $filename);

# Create command and run
my $cmd = 'ffmpeg -y -v error -stats -i "' . $file . '" -compression_level ' . $CFG_PNG_COMPRESSION . ' "' . $filename . '/frame_%06d.png"';
`$cmd`;

print 'Done'."\n";

<STDIN>;
