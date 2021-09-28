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
 
my $fh=new FileHandle "+< $dest";
die "Can not open $dest for extending\n" unless $fh;

binmode($fh);

# Check to ensure we don't already have 15 extensions
sysseek($fh,8,0);
my $ext_byte;
sysread($fh,$ext_byte,1);

$ext_byte=ord($ext_byte);
$ext_byte=160 if $ext_byte==0;
if ($ext_byte < 160 || $ext_byte > 175)
{
  die "Base MMB image has unexpected character indicating length\n  We got $ext_byte but it should be 0 or between 160 and 175\n";
}

die "Already at maximum extent\n" if $ext_byte == 175;

# Seek to end of file
sysseek($fh,0,2);

my $image=BeebUtils::blank_mmb();
syswrite($fh,$image);

# Update extent record
sysseek($fh,8,0);
syswrite($fh,chr($ext_byte+1),1);

close($fh);

print "$dest extended\n";
