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
 
my $extra=$ARGV[0];
if (defined($extra))
{
  die "Syntax: $BeebUtils::PROG [-f MMB_file] [extra_catalogs]\n   extra_catalogues must be a number between 1 and 15 inclusive\n" unless $extra=~/^[0-9]+$/;
;

  $extra=int($extra);
  if ($extra < 1 || $extra > 15)
  {
    die "extra_catalogues must be a number between 1 and 15 inclusive\n";
  }
}
else
{
  $extra=0;
}

my $image=BeebUtils::blank_mmb();

my $fh=new FileHandle ">$dest";
die "Can not open $dest for saving\n" unless $fh;

binmode($fh);
print $fh $image;

if ($extra)
{
  foreach my $i (1..$extra)
  {
    print $fh $image;
  }
  sysseek($fh,8,0);
  syswrite($fh,chr(160+$extra),1);
}

close($fh);

print "Blank $dest created (with $extra additional catalogues)\n";
