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

my $disktable=BeebUtils::LoadDiskTable();
my %disk=BeebUtils::load_dcat();

# For each formatted disk, read the SSD title and update the
# catalogue
foreach (sort {$a <=> $b} keys %disk)
{
  next unless $disk{$_}{Formatted};
  my $image=BeebUtils::read_ssd($_);
  my %files=BeebUtils::read_cat(\$image);
  my $title=$files{""}{title};
  BeebUtils::ChangeDiskName($_,$title,\$disktable);
  printf("%4d: %s\n",$_,$title);
}

BeebUtils::SaveDiskTable(\$disktable);
