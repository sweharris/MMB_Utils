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
 
my $base=$ARGV[0];
if (defined($base))
{
  die "Syntax: $BeebUtils::PROG [-f MMB_file] [base_catalogue]\n   base_catalogue must be a number between 1 and 15 inclusive\n" unless $base=~/^[0-9]+$/;
;

  $base=int($base);
  if ($base < 0 || $base > 15)
  {
    die "base_catalogue must be a number between 0 and 15 inclusive\n";
  }
}

my $fh=new FileHandle "+< $dest";
die "Can not open $dest for extending\n" unless $fh;

binmode($fh);

# Get the number of extents
sysseek($fh,8,0);
my $ext_byte;
sysread($fh,$ext_byte,1);

$ext_byte=ord($ext_byte);
$ext_byte=160 if $ext_byte==0;
if ($ext_byte < 160 || $ext_byte > 175)
{
  die "Base MMB image has unexpected character indicating length\n  We got $ext_byte but it should be 0 or between 160 and 175\n";
}
$ext_byte-=160;

if (!defined($base))
{
  sysread($fh,$base,1);
  print "Current base setting is: " . ord($base) . "\n";
}
else
{
  if ($base > $ext_byte)
  {
    die "MMB only has " . $ext_byte . " additional extents; can not set base to " . $base . "\n";
  }

  syswrite($fh,chr($base),1);
  print "Base set to: $base\n";
}
