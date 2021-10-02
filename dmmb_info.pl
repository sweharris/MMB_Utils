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
 
my $fh=new FileHandle "< $dest";
die "Can not open $dest for reading\n" unless $fh;

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

# Get the base value
my $base;
sysread($fh,$base,1);
$base=ord($base);

my ($disktable,%boot)=BeebUtils::load_onboot();
my %disk=BeebUtils::load_dcat(\$disktable);

my ($disktable2,%boot2)=BeebUtils::load_onboot($base);

my $form=0;
my $tot=0;

foreach (keys %disk)
{
  $tot++;
  $form++ unless $disk{$_}{Formatted};
}

print "MMB Filename: $dest\n" .
      "  Number of extents: " . ($ext_byte-159) . " (0->" . ($ext_byte-160) . ")\n" .
      "        Base extent: $base (image IDs will be offset by " . ($base*511) . ")\n" .
      "    Number of disks: $tot\n" .
      "       #Unformatted: $form\n" .
      "       Onboot disks:\n";

print "             Extent 0: (MMB Base)\n" if $base;

foreach (0..3)
{
  my $d=$boot{$_};
  my $t="<empty>";
  if ($disk{$d}{Formatted})
  {
    my $L=$disk{$d}{ReadOnly}?" (L)":"";
    $t="$disk{$d}{DiskTitle}$L";
  }
  printf("                     %s: %4d - %-12s\n",$_,$d,$t);
}

if ($base)
{
  print "\n             Extent $base: (Currently selected)\n" if $base;
  foreach (0..3)
  {
    my $d=$boot2{$_};
    my $t="<empty>";
    if ($disk{$d+$base*511}{Formatted})
    {
      my $L=$disk{$d+$base*511}{ReadOnly}?" (L)":"";
      $t="$disk{$d+$base*511}{DiskTitle}$L";
    }
    printf("                     %s: %4d - %-12s\n",$_,$d,$t);
  }
}
