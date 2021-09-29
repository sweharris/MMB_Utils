#!/usr/bin/perl -w
use strict;

# Beeb Utilities to manipulate MMB and SSD files
# Copyright (C) 2012 Stephen Harris
# 
# See file "COPYING" for GPLv2 licensing

use FindBin;
use lib "$FindBin::Bin";
use BeebUtils;

@ARGV=BeebUtils::init(@ARGV);
my $dest=$BeebUtils::BBC_FILE || 'BEEB.MMB';

die "$dest does not exists\n" unless -e $dest;
 
die "Syntax: $BeebUtils::PROG [-f MMB_file] file1.mmb cat_number\n" unless @ARGV == 2;

my $source=$ARGV[0];
my $cat=$ARGV[1];

die "Catalogue must be a number\n" unless $cat =~ /^[0-9]+$/;
die "Catalogue must be 0-15\n" if $cat < 0 || $cat > 15;

# Check file exists and looks like it's an MMB file (right size)

my @s=stat($source);
die "Could not stat $source: $!\n" unless @s;
my $len=$s[7];
die "$source is the wrong size; is it an MMB?\n  Found $len, should be " . $BeebUtils::MMBSize . "\n" unless $len == $BeebUtils::MMBSize;

# OK everything looks sane...
my $fh=new FileHandle "+< $dest";
die "Can not open $dest for updating\n" unless $fh;

binmode($fh);

my $image;
my $src=new FileHandle "<$source";
die "Error opening $source: $!\n" unless $src;
sysread($src,$image,$BeebUtils::MMBSize);
close($src);

sysseek($fh,$cat*$BeebUtils::MMBSize,0);
syswrite($fh,$image);

print "$dest updated\n";
