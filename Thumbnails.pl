
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



our $CFG_THUMBSIZE = 300; # Max X or Y dimension of the thumbnails
our $CFG_COLUMNS = 0.9; # multiplier of screen width of 1920
our $CFG_ROWS = 2.2; # multiplier of screen height of 1080
our $CFG_JPEGQUALITY = 3; # output image quality [1-31] (1=best)



# No need to edit below here



use strict;
use Cwd;


# Print current active path
print '[' . cwd() . ']' . "\n";

# Start processing from the current directory
process_directory('.');

print "\n" . 'Done!' . "\n";

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
			
		} elsif ($de =~ /^(.+)\.(mp4|mkv|mov|avi|mpg|mpeg|wmv|m4v|flv|f4v|vob)$/i) {
			# This is a videofile

  			# Get filename and type from regex above
			my $filename = $1;
			my $suffix = $2;
			
			print 'File: ' . $entry_path;
			
			if (-e './screens/' . $filename . '.jpg') {
				# Thumbs file exist, skip
				print ' allready thumbed, skipping...' . "\n";
				
			} else {
				# Thumbify
				process_file($directory, $filename, $suffix);
			}
		}
		
	}
	closedir($DIR);	
}



sub process_file {
	my($folder, $filename, $type) = @_;
	
	print ' working...' . "\n";
	
	# Make temp folder
	mkdir($folder . '/' . $filename . '-temp');

	# Create thumbs and collage image
	my $status = thumbs_file($folder, $filename, $type);
	
	if ($status) {	
		print ', failed' . "\n";
		return;
	}

	# Delete tempframes and workdir	
	print ', Deleting tempfiles';	
	opendir(my $DIR, $folder . '/' . $filename . '-temp');
	foreach my $de (readdir($DIR)) {
		next if ($de =~ /^\.{1,2}$/);
		unlink($folder . '/' . $filename . '-temp/' . $de) or warn 'ERROR: Could not delete temporary file "' . $folder . '/' . $filename . '-temp/' . $de . '"' . "\n";
	}
	closedir($DIR);
	rmdir($folder . '/' . $filename . '-temp') or warn 'ERROR: Could not delete temporary folder "' . $folder . '/' . $filename . '-temp"' . "\n";
	
	print ', ok' . "\n";
}



sub thumbs_file {
	my($folder, $filename, $type) = @_;
	
	# Find media file framecount
	my $cmd = 'ffprobe -v error -select_streams v:0 -show_entries stream=nb_frames -of default=noprint_wrappers=1:nokey=1 "' . $folder . '/' . $filename . '.' . $type . '"';
	my $frame_count = `$cmd`;
	chomp($frame_count);
	print '  Frames: [' . $frame_count . ']';
	unless (defined $frame_count && $frame_count =~ /^[\d]+$/) {
		warn 'ERROR: Frame count doesn\'t look like a valid number' . "\n";
		return 1;
	}

	# Find media file frame width
	$cmd = 'ffprobe -v error -select_streams v:0 -show_entries stream=width -of default=noprint_wrappers=1:nokey=1 "' . $folder . '/' . $filename . '.' . $type . '"';
	my $frame_width = `$cmd`;
	chomp($frame_width);
	print ', Width: [' . $frame_width . ']';
	unless (defined $frame_width && $frame_width =~ /^[\d]+$/) {
		warn 'ERROR: Frame width doesn\'t look like a valid number' . "\n";
		return 1;
	}

	# Find media file frame height
	$cmd = 'ffprobe -v error -select_streams v:0 -show_entries stream=height -of default=noprint_wrappers=1:nokey=1 "' . $folder . '/' . $filename . '.' . $type . '"';
	my $frame_height = `$cmd`;
	chomp($frame_height);
	print ', Height: [' . $frame_height . ']';
	unless (defined $frame_height && $frame_height =~ /^[\d]+$/) {
		warn 'ERROR: Frame height doesn\'t look like a valid number' . "\n";
		return 1;
	}
	
	# Find media average bitrate
	$cmd = 'ffprobe -v error -select_streams v:0 -show_entries format=bit_rate -of default=noprint_wrappers=1:nokey=1 "' . $folder . '/' . $filename . '.' . $type . '"';
	my $bitrate_avg = `$cmd`;
	chomp($bitrate_avg);
	print ', Avg. bitrate: [' . $bitrate_avg . ']';

	# Find media duration
	$cmd = 'ffprobe -v error -select_streams v:0 -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "' . $folder . '/' . $filename . '.' . $type . '"';
	my $duration = `$cmd`;
	chomp($duration);
	print ', Duration: [' . get_duration($duration) . ']';

	# Find filesize
	my $filesize = get_file_size($folder . '/' . $filename . '.' . $type);
	
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
	
	# Calculate row+column count
	my $cols = int(1920 / $scaled_width * $CFG_COLUMNS);
	my $rows = int(1080 / $scaled_height * $CFG_ROWS);
	
	# Extract thumb frames into temp folder
	print ', Generating ' . ($cols * $rows) . ' thumbnails';
	$cmd = 'ffmpeg -y -v error -i "' . $folder . '/' . $filename . '.' . $type . '" -vf "';
	$cmd .= 'select=\'';
	foreach my $i (1..($cols * $rows)) {
		my $frame = $i * ($frame_count / (($cols * $rows) + 1));
		$cmd .= 'eq(n\,' . int($frame) . ')';
		$cmd .= '+' if ($i < ($cols * $rows));
	}	
	$cmd .= '\'';
	$cmd .= ',scale=' . $scaled_width . ':' . $scaled_height;
	$cmd .= ',unsharp=5:5:1.0';
	$cmd .= '" -vsync vfr -compression_level 0 "' . $folder . '/' . $filename . '-temp/frame%d.png' . '"';
	open(my $ELOG, '>>' . $folder . '/' . $filename . '-temp/Thumbnails.log');
	print $ELOG $cmd . "\n\n";
	close($ELOG);
	`$cmd`;
	
	# Create "screens" folder if necessary
	mkdir('./screens') or die 'ERROR: Could not create "screens" folder' . "\n" unless (-d './screens');
	
	# Build ffmpeg command for composite image
	$cmd = 'ffmpeg -y -v quiet';
	foreach my $i (1..($cols * $rows)) {
		$cmd .= ' -i "' . $folder . '/' . $filename . '-temp/frame' . $i . '.png' . '"'
	}
	$cmd .= ' -filter_complex "';
	foreach my $i (1..($cols * $rows)) {
		$cmd .= '[' . ($i - 1) . ':v]';
	}
	$cmd .= 'xstack=inputs=' . ($cols * $rows) . ':layout=';
	foreach my $row (0..($rows - 1)) {
		foreach my $col (0..($cols - 1)) {
			$cmd .= ($col * $scaled_width) . '_' . ($row * $scaled_height);
			$cmd .= '|' if (($row < ($rows - 1)) || ($col < ($cols - 1)));
		}
	}
	$cmd .= ',drawtext=fontfile=\'C\:/Windows/Fonts/calibri.ttf\':text=\'' . get_escaped($folder . '/' . $filename . '.' . $type) . '\':x=10:y=10:fontsize=50:fontcolor=white:box=1:boxcolor=black@0.4';	
	$cmd .= ',drawtext=fontfile=\'C\:/Windows/Fonts/calibri.ttf\':text=\'' . get_escaped($filesize . ', ' . get_duration($duration) . ', ' . $frame_width . 'x' . $frame_height . ', ' . get_averate_bitrate($bitrate_avg)) . '\':x=10:y=60:fontsize=50:fontcolor=white:box=1:boxcolor=black@0.4';
	$cmd .= ',scale=' . ($cols * $scaled_width) . ':' . ($rows * $scaled_height);
	$cmd .= '" -frames:v 1 -qmin 1 -q:v ' . $CFG_JPEGQUALITY . ' "./screens/' . $filename . '.jpg"';
	print ', Saving jpg';
	`$cmd`;
	print ' [' . get_file_size('./screens/' . $filename . '.jpg') . ']';
	unless (get_file_size('./screens/' . $filename . '.jpg') =~ /^\d+/) {
		open(my $ELOG, '>>Thumbnails.log');
		print $ELOG 'ERROR: Produced no file' . "\n" . $cmd . "\n\n";
		close($ELOG);
		return 2;
	}
	
	return 0;
}



sub get_file_size {
	my($filepath) = @_;
	
	# Early exit if file does not exist
	return 'File not found' unless (-e $filepath);
	
	# Read filesize
	my $filesize = -s $filepath;
	
	# Return shortened large size
	return sprintf("%.1f GB", $filesize / 1_000_000_000) if ($filesize > 900_000_000);
    return sprintf("%.1f MB", $filesize / 1_000_000) if ($filesize > 900_000);
    return sprintf("%.1f KB", $filesize / 1_000) if ($filesize > 900);

	# Or return small size
    return $filesize . ' bytes';
}



sub get_escaped {
	my($string) = @_;
	
	# Single quotes mess up the command, so remove. See also ffmpeg docs regarding this
	$string =~ s/'//g;

	# Columns should be escaped
	$string =~ s/:/\\:/g;

	return $string;
}



sub get_duration {
	my($seconds) = @_;
	
	# Input validation
    return '00:00:00' unless (defined $seconds && $seconds >= 0);
	
	# Calculate hours, minutes, and seconds
	my $hours = int($seconds / 3600);
	my $minutes = int(($seconds % 3600) / 60);
	my $secs = int($seconds % 60);
	
	# Format as HH:MM:SS
	return sprintf("%02d:%02d:%02d", $hours, $minutes, $secs);
}



sub get_averate_bitrate {
	my($bitrate) = @_;
	
	# Input validation
    return '[N/A]' unless (defined $bitrate && $bitrate >= 0);
	
	# Return shortened large bitrate
	return sprintf("%.1f Gbit/s", $bitrate / 1_000_000_000) if ($bitrate > 900_000_000);
    return sprintf("%.1f Mbit/s", $bitrate / 1_000_000) if ($bitrate > 900_000);
    return sprintf("%.1f Kbit/s", $bitrate / 1_000) if ($bitrate > 900);

	# Or return small bitrate
    return $bitrate . ' bit/s';
}
