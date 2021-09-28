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
my $src=$BeebUtils::BBC_FILE || 'BEEB.MMB';

die "Syntax: $BeebUtils::PROG [-f MMB_File] destdir [extent]\n" if !@ARGV;

my $destdir=$ARGV[0];
my $want_extent=$ARGV[1];

if (defined($want_extent) && $want_extent !~ /^[0-9]+$/)
{
  die "Extent must be a number\n";
}

$want_extent=-1 unless defined($want_extent);

die "$destdir already exists\n" if -e $destdir;
mkdir($destdir) || die "mkdir $destdir: $!\n";

my $fh=new FileHandle "< $src";
die "Can not open $src for reading\n" unless $fh;

binmode($fh);

# How many extents do we have
sysseek($fh,8,0);
my $ext_byte;
sysread($fh,$ext_byte,1);

$ext_byte=ord($ext_byte);
$ext_byte=160 if $ext_byte==0;
if ($ext_byte < 160 || $ext_byte > 175)
{
  die "Base MMB image has unexpected character indicating length\n  We got $ext_byte but it should be 0 or between 160 and 175\n";
}

my $data;

foreach my $extent (0..$ext_byte-160)
{
  next if $want_extent != -1 && $extent != $want_extent;

  my $newname=sprintf("%X",$extent);
  sysseek($fh,$extent*$BeebUtils::MMBSize,0);
  sysread($fh,$data,$BeebUtils::MMBSize);

  # Ensure there is no extent information in this image
  substr($data,8,1)=chr(0);

  my $newfile=new FileHandle "> $destdir/$newname.MMB";
  die "Could not create $destdir/$newname.MMB" unless $newfile;
  print $newfile $data;
  close($newfile);
  print "Created $destdir/$newname.MMB\n";
}
