#!/usr/bin/perl -w
use strict;

# Beeb Utilities to manipulate MMB and SSD files
# Copyright (C) 2012 Stephen Harris
# 
# See file "COPYING" for GPLv2 licensing

use FindBin;
use lib "$FindBin::Bin";
use BeebUtils;

@ARGV=BeebUtils::init_ssd(@ARGV);

my $merge=0;
if (@ARGV && $ARGV[0] eq '-merge')
{
  $merge=1; shift @ARGV;
}

my $overwrite=0;
if (@ARGV && $ARGV[0] eq '-overwrite')
{
  $overwrite=1; shift @ARGV;
}

die "Syntax: $BeebUtils::PROG filename.ssd [-merge] [-overwrite] destdir [filename_regexp]\n" if $BeebUtils::BBC_FILE eq "" || !@ARGV;

my $destdir=$ARGV[0];

my $filter='^.*$';
if (defined $ARGV[1]) {
    $filter = $ARGV[1];
}

if ($merge)
{
    if (!-d $destdir) {
        mkdir($destdir) || die "mkdir $destdir: $!\n";
    }
} else {
    die "$destdir already exists\n" if -e $destdir;
    mkdir($destdir) || die "mkdir $destdir: $!\n";
}

my $image=BeebUtils::load_external_ssd(undef,0);

chdir($destdir) || die "chdir $destdir: $!\n";
BeebUtils::save_all_files_from_ssd(\$image,1,$overwrite,$filter);
