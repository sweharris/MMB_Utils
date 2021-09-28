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

die "$dest already exists\n" if -e $dest;
 
die "Syntax: $BeebUtils::PROG [-f MMB_file] file1.mmb [file2.mmb ...]\n" unless @ARGV;
die "Max 16 images" if @ARGV > 16;

my @source=@ARGV;

# Check each file exists and looks like it's an MMB file (right size)

foreach (@source)
{
  my @s=stat($_);
  die "Could not stat $_: $!\n" unless @s;
  my $len=$s[7];
  die "$_ is the wrong size; is it an MMB?\n  Found $len, should be " . $BeebUtils::MMBSize . "\n" unless $len == $BeebUtils::MMBSize;
}

# OK everything looks sane...
my $fh=new FileHandle ">$dest";
die "Can not open $dest for saving\n" unless $fh;

binmode($fh);
foreach (@source)
{
  my $image;
  my $src=new FileHandle "<$_";
  die "Error opening $_: $!\n  $dest is incomplete\n" unless $src;
  sysread($src,$image,$BeebUtils::MMBSize);
  close($src);

  syswrite($fh,$image);
}

# Write out the number of catalogues
sysseek($fh,8,0);
my $ext=159+@source;
$ext=0 if $ext==160;
syswrite($fh,chr($ext),1);

close($fh);

print "$dest created\n";
