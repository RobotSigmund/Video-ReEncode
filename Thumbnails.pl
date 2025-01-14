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



our $CFG_THUMBSIZE = 240; # Max X or Y dimension of the thumbnails
our $CFG_COLUMNS = 0.9; # multiplier of screen width of 1920
our $CFG_ROWS = 3; # multiplier of screen height of 1080



# No need to edit below here



use strict;

print '['.$0.']'."\n";

# Start processing from the current directory
process_directory('.');

print "\n".'Done!'."\n";

<STDIN>;



exit;

sub thumbs_file {
	my($folder, $filename, $type) = @_;
	
	# Find media file framecount
	my $cmd = 'ffprobe -v error -select_streams v:0 -show_entries stream=nb_frames -of default=noprint_wrappers=1:nokey=1 "'.$folder.'/'.$filename.'.'.$type.'"';
	my $frame_count = `$cmd`;
	chomp($frame_count);
	print '  Frames: ['.$frame_count.']';
	if ($frame_count !~ /^[\d]+$/) {
		print "\n".'ERROR: Frame count doesn\'t look like a value'."\n";
		return 1;
	}

	# Find media file frame width
	$cmd = 'ffprobe -v error -select_streams v:0 -show_entries stream=width -of default=noprint_wrappers=1:nokey=1 "'.$folder.'/'.$filename.'.'.$type.'"';
	my $frame_width = `$cmd`;
	chomp($frame_width);
	print ', Width: ['.$frame_width.']';
	if ($frame_width !~ /^[\d]+$/) {
		print "\n".'ERROR: Frame width doesn\'t look like a value'."\n";
		return 1;
	}

	# Find media file frame height
	$cmd = 'ffprobe -v error -select_streams v:0 -show_entries stream=height -of default=noprint_wrappers=1:nokey=1 "'.$folder.'/'.$filename.'.'.$type.'"';
	my $frame_height = `$cmd`;
	chomp($frame_height);
	print ', Height: ['.$frame_height.']';
	if ($frame_height !~ /^[\d]+$/) {
		print "\n".'ERROR: Frame height doesn\'t look like a value'."\n";
		return 1;
	}
	
	# Find media average bitrate
	$cmd = 'ffprobe -v error -select_streams v:0 -show_entries format=bit_rate -of default=noprint_wrappers=1:nokey=1 "'.$folder.'/'.$filename.'.'.$type.'"';
	my $bitrate_avg = `$cmd`;
	chomp($bitrate_avg);
	print ', Avg. bitrate: ['.$bitrate_avg.']';

	# Find media duration
	$cmd = 'ffprobe -v error -select_streams v:0 -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "'.$folder.'/'.$filename.'.'.$type.'"';
	my $duration = `$cmd`;
	chomp($duration);
	print ', Duration: ['.$duration.']';

	# Find filesize
	my $filesize = getFileSize($folder.'/'.$filename.'.'.$type);
	
	# Calculate thumbs dimensions
	my $scaled_width;
	my $scaled_height;
	if ($frame_width > $frame_height) {
		$scaled_width = $CFG_THUMBSIZE;
		$scaled_height = int($frame_height * ($CFG_THUMBSIZE / $frame_width));
	} else {
		$scaled_height = $CFG_THUMBSIZE;
		$scaled_width = int($frame_width * ($CFG_THUMBSIZE / $frame_height));
	}
	
	my $cols = int(1920 / $scaled_width * $CFG_COLUMNS);
	my $rows = int(1080 / $scaled_height * $CFG_ROWS);
	
	# Extract thumb frames into temp folder
	print ', Generating '.($cols * $rows).' thumbnails';
	$cmd = 'ffmpeg -y -v error -i "'.$folder.'/'.$filename.'.'.$type.'" -vf "';
	$cmd .= 'select=\'';
	foreach my $i (1..($cols * $rows)) {
		my $frame = $i * ($frame_count / (($cols * $rows) + 1));
		$cmd .= 'eq(n\,'.int($frame).')';
		$cmd .= '+' if ($i < ($cols * $rows));
	}	
	$cmd .= '\'';
	$cmd .= ',scale='.$scaled_width.':'.$scaled_height;
	$cmd .= ',unsharp=5:5:1.0';
	$cmd .= '" -vsync vfr -q:v 1 "'.$folder.'/'.$filename.'-temp/frame%d.jpg'.'"';
	`$cmd`;
	
	# Create "screens" folder if necessary
	mkdir('./screens') if (!(-e './screens'));
	
	# Build ffmpeg command for composite image
	$cmd = 'ffmpeg -y -v quiet';
	foreach my $i (1..($cols * $rows)) {
		$cmd .= ' -i "'.$folder.'/'.$filename.'-temp/frame'.$i.'.jpg'.'"'
	}
	$cmd .= ' -filter_complex "';
	foreach my $i (1..($cols * $rows)) {
		$cmd .= '['.($i - 1).':v]';
	}
	$cmd .= 'xstack=inputs='.($cols * $rows).':layout=';
	foreach my $row (0..($rows - 1)) {
		foreach my $col (0..($cols - 1)) {
			$cmd .= ($col * $scaled_width).'_'.($row * $scaled_height);
			$cmd .= '|' if (($row < ($rows - 1)) || ($col < ($cols - 1)));
		}
	}
	$cmd .= ',drawtext=fontfile=\'C\:/Windows/Fonts/calibri.ttf\':text=\''.getEscaped($folder.'/'.$filename.'.'.$type).'\':x=10:y=10:fontsize=50:fontcolor=white:box=1:boxcolor=black@0.4';	
	$cmd .= ',drawtext=fontfile=\'C\:/Windows/Fonts/calibri.ttf\':text=\''.getEscaped($filesize.', '.getDuration($duration).', '.$frame_width.'x'.$frame_height.', '.getAvgBitrate($bitrate_avg)).'\':x=10:y=60:fontsize=50:fontcolor=white:box=1:boxcolor=black@0.4';
	$cmd .= ',scale='.($cols * $scaled_width).':'.($rows * $scaled_height);
	$cmd .= '" -frames:v 1 -q:v 1 "./screens/'.$filename.'.jpg"';
	print ', Saving jpg';
	#print "\n".'['.$cmd.']'."\n";
	`$cmd`;
	
	return 0;
}



sub getEscaped {
	my($string) = @_;
	$string =~ s/'/'\\''/g;
	$string =~ s/:/\\:/g;
	return $string;
}



sub getDuration {
	my($seconds) = @_;
	my $h = int($seconds / (60 * 60));
	my $m = int(($seconds - ($h * 60 * 60)) / 60);
	my $s = int($seconds - ($h * 60 * 60) - ($m * 60));
	return sprintf("%02d", $h).':'.sprintf("%02d", $m).':'.sprintf("%02d", $s);
}



sub getAvgBitrate {
	my($value) = @_;
	if ($value > 900000000) {
		return (int($value / 90000000) / 10).'Gbit/s';		
	} elsif ($value > 900000) {
		return (int($value / 90000) / 10).'Mbit/s';		
	} elsif ($value > 900) {
		return (int($value / 90) / 10).'Kbit/s';		
	}
}



sub getFileSize {
	my($filepath) = @_;
	my $filesize = (-s $filepath);
	if ($filesize > 900000000) {
		return (int($filesize / 90000000) / 10).'GB';		
	} elsif ($filesize > 900000) {
		return (int($filesize / 90000) / 10).'MB';		
	} elsif ($filesize > 900) {
		return (int($filesize / 90) / 10).'KB';		
	}
}



sub process_file {
	my($folder, $filename, $type) = @_;
	
	print ' working...'."\n";
	
	# Make temp folder
	mkdir($folder.'/'.$filename.'-temp');
	
	my $status = thumbs_file($folder, $filename, $type);
	
	# Delete tempframes and workdir	
	print ', Deleting tempfiles';	
	opendir(my $DIR, $folder.'/'.$filename.'-temp');
	foreach my $de (readdir($DIR)) {
		unlink($folder.'/'.$filename.'-temp/'.$de);
	}
	closedir($DIR);
	rmdir($folder.'/'.$filename.'-temp');
	
	if ($status) {
		print ', failed'."\n";
	} else {
		print ', ok'."\n";
	}
}



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
			
		} elsif ($de =~ /^(.+)\.(mp4|mkv|mov|avi|mpg|mpeg|wmv|m4v|flv|f4v|vob)$/i) {
			# This is a videofile

  			# Get filename and type from regex above
			my $filename = $1;
			my $suffix = $2;
			
			print 'File: '.$entry_path;
			
			if (-e ('./screens/'.$filename.'.jpg')) {
				# Thumbs file exist, skip
				print ' allready thumbed, skipping...'."\n";
				
			} else {
				# Thumbify
				process_file($directory, $filename, $suffix);
			}
		}
		
	}
	closedir($DIR);	
}
